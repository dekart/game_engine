class AppRequest::Base < ActiveRecord::Base
  set_table_name :app_requests
  
  belongs_to :sender, :class_name => "Character"
  
  named_scope :for, Proc.new {|character|
    {
      :conditions => {:receiver_id => character.facebook_id}
    }
  }
  named_scope :from, Proc.new{|character|
    {
      :conditions => {:sender_id => character.id}
    }
  }
  named_scope :between, Proc.new{|sender, receiver|
    {
      :conditions => {:sender_id => sender.id, :receiver_id => receiver.facebook_id}
    }
  }

  state_machine :initial => :pending do
    state :processed
    state :visited
    state :accepted
    state :ignored

    event :process do
      transition :pending => :processed
    end

    event :visit do
      transition [:pending, :processed] => :visited
    end
    
    event :accept do
      transition [:pending, :processed] => :accepted
    end
    
    event :ignore do
      transition [:pending, :processed] => :ignored
    end
    
    after_transition :on => :process do |request|
      request.update_attribute(:processed_at, Time.now)
    end

    after_transition :on => :visit do |request|
      request.update_attribute(:visited_at, Time.now)
    end

    after_transition :on => :accept do |request|
      request.send(:after_accept)
    end
  end

  serialize :data
  
  validates_presence_of :facebook_id
  
  after_create :schedule_data_update
  
  class << self
    def schedule_deletion(*ids_or_requests)
      ids = ids_or_requests.compact.collect{|value| value.is_a?(AppRequest) ? value.id : value}
      
      Delayed::Job.enqueue(Jobs::RequestDelete.new(ids)) unless ids.empty?
    end
    
    def receiver_ids
      all(:select => :receiver_id).collect{|r| r.receiver_id }
    end
  end
  
  def receiver
    @receiver ||= User.find_by_facebook_id(receiver_id).try(:character)
  end

  def update_data!
    request = Mogli::AppRequest.find(facebook_id, Mogli::AppClient.create_and_authenticate_as_application(Facebooker2.app_id, Facebooker2.secret))
    
    self.sender = User.find_by_facebook_id(request.from.id).character
    self.receiver_id = request.to.id
    self.data = JSON.parse(request.data) if request.data
    
    save!
    
    process
  end
  
  def delete_from_facebook!
    Mogli::AppRequest.new(
      {:id => facebook_id}, 
      Mogli::AppClient.create_and_authenticate_as_application(Facebooker2.app_id, Facebooker2.secret)
    ).destroy
  end

  def type_name
    self.class.name.split('::')[1].underscore
  end
  
  def acceptable?
    true
  end

  protected
  
  def after_accept
    update_attribute(:accepted_at, Time.now)
    
    self.class.schedule_deletion(id)
  end
  
  def schedule_data_update
    Delayed::Job.enqueue Jobs::RequestDataUpdate.new(id)
  end
end
