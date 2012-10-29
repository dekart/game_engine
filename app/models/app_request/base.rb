class AppRequest::Base < ActiveRecord::Base
  self.table_name = :app_requests

  belongs_to :sender, :class_name => "Character"

  belongs_to :target, :polymorphic => true

  scope :by_type, Proc.new {|type|
    {
      :conditions => ["type = ?", request_class_name_for_type(type)],
      :order => "sender_id, type, created_at DESC"
    }
  }

  scope :for_character, Proc.new {|character|
    {
      :conditions => {:receiver_id => character.facebook_id}
    }
  }
  scope :from_character, Proc.new{|character|
    {
      :conditions => {:sender_id => character.id}
    }
  }
  scope :between, Proc.new{|sender, receiver|
    {
      :conditions => {
        :sender_id    => sender.id,
        :receiver_id  => receiver
      }
    }
  }
  scope :with_target, Proc.new{|target|
    {
      :conditions => {
        :target_id    => target,
        :target_type  => target.class.sti_name
      }
    }
  }
  scope :without, Proc.new{|request|
    {
      :conditions => ["app_requests.id != ?", request.id]
    }
  }
  scope :sent_before, Proc.new{|time|
    {
      :conditions => ["sent_at < :time OR (sent_at IS NULL AND created_at < :time)", {:time => time.utc}]
    }
  }
  scope :sent_after, Proc.new{|time|
    {
      :conditions => ["sent_at > :time OR (sent_at IS NULL AND app_requests.created_at > :time)", {:time => time.utc}]
    }
  }
  scope :accepted_after, Proc.new{|time|
    {
      :conditions => ["accepted_at >= ?", time.utc]
    }
  }

  scope :visible, :conditions => {:state => ['processed', 'visited']}
  scope :for_expire, :conditions => {:state => ['pending', 'processed', 'visited']}

  state_machine :initial => :pending do
    state :processed
    state :visited
    state :accepted
    state :ignored
    state :broken
    state :expired # when user don't accept request in time
    state :incorrect

    event :process do
      transition :pending => :processed
    end

    event :mark_broken do
      transition :pending => :broken
    end

    event :mark_incorrect do
      transition :processed => :incorrect
    end

    event :visit do
      transition [:pending, :processed] => :visited
    end

    event :accept do
      transition [:processed, :visited] => :accepted
    end

    event :ignore do
      transition [:pending, :processed, :visited] => :ignored
    end

    event :expire do
      transition [:pending, :processed, :visited] => :expired
    end

    before_transition :on => [:process, :mark_broken] do |request|
      request.processed_at = Time.now
    end

    after_transition :on => :process do |request|
      request.send(:after_process)
    end

    before_transition :on => :visit do |request|
      request.visited_at = Time.now
    end

    before_transition :on => :accept do |request|
      request.send(:before_accept)
    end

    after_transition :on => :accept do |request|
      request.send(:after_accept)
    end

    after_transition :on => :ignore do |request|
      request.send(:after_ignore)
    end

    before_transition :on => :expire do |request|
      request.send(:before_expire)
    end

    after_transition :on => :expire do |request|
      request.send(:after_expire)
    end
  end

  validates_presence_of :facebook_id

  after_create  :schedule_data_update
  after_save    :clear_counter_cache,     :if => :receiver_id?
  after_save    :clear_exclude_ids_cache, :if => :sender

  class << self
    def cache_key(target)
      "user_#{ target.is_a?(User) ? target.facebook_id : target.to_i }_app_request_counter"
    end

    def exclude_ids_cache_key(character)
      "#{ sti_name.underscore }_exclude_ids_#{ character.id }"
    end

    def schedule_deletion(*ids_or_requests)
      ids = ids_or_requests.flatten.compact.collect{|value| value.is_a?(AppRequest::Base) ? value.id : value}.uniq

      Delayed::Job.enqueue(Jobs::RequestDelete.new(ids)) unless ids.empty?
    end

    def receiver_ids
      all(:select => "DISTINCT receiver_id").collect{|r| r.receiver_id }
    end

    def check_request(request_id, recipient_ids)
      fbids = recipient_ids.map{|r| "#{ request_id }_#{ r }"}

      begin
        Facepalm::Config.default.api_client.get_objects(fbids).each do |id, graph_data|
          request_from_graph_data(graph_data)
        end
      rescue Exception => e
        Rails.logger.error e
      end
    end

    def check_user_requests(user)
      user.facebook_client.get_connections('me', 'apprequests').each do |graph_data|
        request_from_graph_data(graph_data)
      end
    rescue Koala::Facebook::APIError => e
      Rails.logger.error e
    end

    def request_from_graph_data(graph_data)
      data = JSON.parse(graph_data['data']) if graph_data['data']

      request = class_from_data(data).find_or_initialize_by_facebook_id_and_receiver_id(*graph_data['id'].split('_'))

      request.update_from_facebook_request(graph_data, data) if request.pending?
    end

    def types
      all(
          :select => "type, COUNT(type) as count_requests",
          :group => "type"
         ).collect{|a| {:name => a.type_name, :count => a.count_requests}}
    end

    def request_class_name_for_type(type)
      "AppRequest::#{ type.camelize }"
    end

    def class_from_data(data)
      if data.is_a?(Hash) && %w{gift invitation monster_invite property_worker clan_invite}.include?(data['type'])
        "AppRequest::#{ data['type'].camelize }"
      else
        'AppRequest::Invitation'
      end.constantize
    end
  end

  def receiver
    @receiver ||= User.find_by_facebook_id(receiver_id).try(:character)
  end

  def update_from_facebook_request(facebook_request, data)
    if facebook_request['from'].nil?
      ignore!
    else
      # Ensure that the new type will be saved correctly
      self.type = self.class.class_from_data(data).name

      self.sender = User.find_by_facebook_id(facebook_request['from']['id']).character
      self.receiver_id = facebook_request['to']['id'] if facebook_request['to']

      self.sent_at = Time.parse(facebook_request["created_time"]).utc

      transaction do
        save!

        # TODO: hack. Rails 2.3.11 dont save target in usual way (self.target = ... or request.target = )
        if data && data['target_id'] && data['target_type']
          self.target = data['target_type'].constantize.find(data['target_id'])
        end

        self.process
      end
    end
  end

  def graph_api_id
    receiver_id ? "#{ facebook_id }_#{ receiver_id }" : facebook_id
  end

  def delete_from_facebook!
    Facepalm::Config.default.api_client.delete_object(graph_api_id)
  rescue Koala::Facebook::APIError => e
    logger.error "AppRequest data update error: #{ e }"

    mark_broken! if can_mark_broken?
  end

  def type_name
    self.class.name.split('::')[1].underscore
  end

  def acceptable?
    true
  end

  def correct?
    true
  end

  protected

  def before_accept
    self.accepted_at = Time.now
  end

  def after_accept
    self.class.schedule_deletion(self)
  end

  def after_ignore
    self.class.schedule_deletion(self)
  end

  def before_expire
    self.expired_at = Time.now
  end

  def after_expire
    self.class.schedule_deletion(self)
  end

  def after_process
    if later_similar_requests.count > 0
      ignore
    elsif !correct?
      mark_incorrect
    end

    previous_similar_requests.with_state(:processed, :visited).each do |request|
      request.ignore
    end
  end

  def previous_similar_requests
    self.class.between(sender, receiver_id).without(self).sent_before(sent_at)
  end

  def later_similar_requests
    self.class.between(sender, receiver_id).without(self).sent_after(sent_at)
  end

  def schedule_data_update
    if self.class == AppRequest::Base
      Delayed::Job.enqueue Jobs::RequestDataUpdate.new(id)
    end
  end

  def clear_counter_cache
    Rails.cache.delete(self.class.cache_key(receiver_id))

    true
  end

  def clear_exclude_ids_cache
    Rails.cache.delete(self.class.exclude_ids_cache_key(sender))

    true
  end
end
