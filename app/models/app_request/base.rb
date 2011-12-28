class AppRequest::Base < ActiveRecord::Base
  set_table_name :app_requests
  
  belongs_to :sender, :class_name => "Character"
  
  belongs_to :target, :polymorphic => true
  
  named_scope :for_character, Proc.new {|character|
    {
      :conditions => {:receiver_id => character.facebook_id}
    }
  }
  named_scope :from_character, Proc.new{|character|
    {
      :conditions => {:sender_id => character.id}
    }
  }
  named_scope :between, Proc.new{|sender, receiver|
    {
      :conditions => {
        :sender_id    => sender.id, 
        :receiver_id  => receiver
      }
    }
  }
  named_scope :with_target, Proc.new{|target|
    {
      :conditions => {
        :target_id    => target,
        :target_type  => target.class.sti_name
      }
    }
  }
  named_scope :without, Proc.new{|request|
    {
      :conditions => ["app_requests.id != ?", request.id]
    }
  }
  named_scope :sent_before, Proc.new{|time|
    {
      :conditions => ["sent_at < :time OR (sent_at IS NULL AND created_at < :time)", {:time => time.utc}]
    }
  }
  named_scope :sent_after, Proc.new{|time|
    {
      :conditions => ["sent_at > :time OR (sent_at IS NULL AND app_requests.created_at > :time)", {:time => time.utc}]
    }
  }
  named_scope :accepted_after, Proc.new{|time|
    {
      :conditions => ["accepted_at >= ?", time.utc]
    }
  }
  
  named_scope :visible, :conditions => {:state => ['processed', 'visited']}
  named_scope :for_expire, :conditions => {:state => ['pending', 'processed', 'visited']}
  
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

  serialize :data
  
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
    
    def check_user_requests(user)
      user.facebook_client.get_connections('me', 'apprequests').each do |facebook_request|
        request = AppRequest::Base.find_or_initialize_by_facebook_id_and_receiver_id(*facebook_request['id'].split('_'))
        
        request.update_from_facebook_request(facebook_request) if request.pending?
      end
    end
  end
  
  def receiver
    @receiver ||= User.find_by_facebook_id(receiver_id).try(:character)
  end
  
  def update_from_facebook_request(facebook_request)
    if facebook_request['from'].nil?
      ignore!
    else
      self.data = JSON.parse(facebook_request['data']) if facebook_request['data']
  
      becomes(request_class_from_data).tap do |request|
        # Ensure that the new type will be saved correctly
        request.type = request.class.sti_name
      
        request.sender = User.find_by_facebook_id(facebook_request['from']['id']).character
        request.receiver_id = facebook_request['to']['id'] if facebook_request['to']

        request.sent_at = Time.parse(facebook_request["created_time"]).utc
        
        request.transaction do
          request.save!
          
          # TODO: hack. Rails 2.3.11 dont save target in usual way (self.target = ... or request.target = )
          if data && data['target_id'] && data['target_type']
            request.target = data['target_type'].constantize.find(data['target_id'])
          end
          
          request.process
        end
      end
    end
  end
  
  def graph_api_id
    receiver_id ? "#{ facebook_id }_#{ receiver_id }" : facebook_id
  end

  def update_data!
    if graph_data = Facepalm::Config.default.api_client.get_object(graph_api_id)
      update_from_facebook_request(graph_data)
    else
      logger.error "Request cannot be fetched using Graph API: #{ graph_api_id }"

      mark_broken! if can_mark_broken?
    end
  rescue Koala::Facebook::APIError => e
    logger.error "AppRequest data update error: #{ e }"

    mark_broken! if can_mark_broken?
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
  
  def request_class_from_data
    if data.is_a?(Hash) && %w{gift invitation monster_invite property_worker clan_invite}.include?(data['type'])
      "AppRequest::#{ data['type'].camelize }"
    else
      'AppRequest::Invitation'
    end.constantize
  end
  
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
  end
  
  def clear_exclude_ids_cache
    Rails.cache.delete(self.class.exclude_ids_cache_key(sender))
  end
end
