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
    def type_name
      @type_name ||= name.split('::')[1].underscore
    end

    def stackable?
      false
    end

    def find_by_graph_id(id)
      facebook_id, receiver = id.split('_')

      where(:facebook_id => facebook_id, :receiver_id => receiver).first
    end

    def cache_key(target)
      "user_#{ target.is_a?(User) ? target.facebook_id : target.to_i }_app_request_counter"
    end

    def exclude_ids_cache_key(character)
      "#{ sti_name.underscore }_exclude_ids_#{ character.id }"
    end

    def schedule_deletion(*ids_or_requests)
      ids = ids_or_requests.flatten.compact.collect{|value| value.is_a?(AppRequest::Base) ? value.graph_api_id : value}.uniq

      ids.each do |id|
        $redis.sadd("app_requests_for_deletion", id)
      end
    end

    def delete_from_facebook!(ids)
      result = Facepalm::Config.default.api_client.batch do |batch_api|
        ids.collect{|id| batch_api.delete_object(id) }
      end

      result.each_with_index do |r, i|
        next unless r.is_a?(Koala::Facebook::APIError)

        result[i] = r.message.include?('Specified object cannot be found') || r.message.include?('Permissions error')
      end
    end

    def reschedule_failed_for_deletion
      failed = $redis.smembers("app_requests_failed_deletion")

      failed.each do |id|
        $redis.multi do
          $redis.sadd('app_requests_for_deletion', id)
          $redis.srem('app_requests_failed_deletion', id)
        end
      end
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
      user.facebook_client.get_connections('me', 'apprequests', :limit => 1000).each do |graph_data|
        request_from_graph_data(graph_data)
      end
    rescue Koala::Facebook::APIError => e
      Rails.logger.error e
    end

    def request_from_graph_data(graph_data)
      data = JSON.parse(graph_data['data']) if graph_data['data']

      request = class_from_data(data).find_or_initialize_by_facebook_id_and_receiver_id(*graph_data['id'].split('_'))

      if request.pending?
        request.update_from_facebook_request(graph_data, data)
      elsif not (request.processed? or request.visited?)
        schedule_deletion(request)
      end
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

    def class_from_type(type)
      if %w{gift invitation monster_invite property_worker clan_invite}.include?(type)
        "AppRequest::#{ type.camelize }".constantize
      else
        AppRequest::Invitation
      end
    end

    def class_from_data(data)
      if data.is_a?(Hash)
        class_from_type(data['type'])
      else
        AppRequest::Invitation
      end
    end

    def target_from_data(data)
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

        self.target = self.class.target_from_data(data)

        self.process
      end
    end
  end

  def graph_api_id
    receiver_id ? "#{ facebook_id }_#{ receiver_id }" : facebook_id
  end

  def type_name
    self.class.type_name
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
