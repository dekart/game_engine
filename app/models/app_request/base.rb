class AppRequest::Base < ActiveRecord::Base
  set_table_name :app_requests_new
  
  belongs_to :sender, :class_name => "Character"
  
  named_scope :for_character, Proc.new {|character|
    {
      :conditions => {:receiver_id => character.user.facebook_id}
    }
  }

  state_machine :initial => :pending do
    state :processed
    state :visited
    state :accepted

    event :process do
      transition :pending => :processed
    end

    event :visit do
      transition [:pending, :processed] => :visited
    end
    
    event :accept do
      transition [:pending, :processed] => :accepted
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
  end
  
  def receiver
    @receiver ||= User.find_by_facebook_id(receiver_id).try(:character)
  end

  def update_data!
    request = Mogli::AppRequest.find(facebook_id, Mogli::AppClient.create_and_authenticate_as_application(Facebooker2.app_id, Facebooker2.secret))
    
    self.sender = User.find_by_facebook_id(request.from.id).character
    self.receiver_id = request.to.id
    self.data = JSON.parse(request.data)
    
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
    raise 'Not Implemented'
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
