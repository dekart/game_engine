class AppRequest < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  
  serialize :data
  
  validates_presence_of :facebook_id
  
  after_create :schedule_data_update
  after_update :process_request, :if => :data_changed?
  
  class << self
    def schedule_deletion(*ids_or_requests)
      ids = ids_or_requests.compact.collect{|value| value.is_a?(AppRequest) ? value.id : value}
      
      Delayed::Job.enqueue(Jobs::RequestDelete.new(ids)) unless ids.empty?
    end
  end
  
  def reference
    data ? data['reference'] : ''
  end
  
  def return_to
    data && data['return_to'].present? ? data['return_to'] : nil
  end
  
  def update_data!
    request = Mogli::AppRequest.find(facebook_id, Mogli::AppClient.create_and_authenticate_as_application(Facebooker2.app_id, Facebooker2.secret))
    
    self.sender = User.find_by_facebook_id(request.from.id)
    self.receiver_id = request.to.id
    self.data = JSON.parse(request.data)
    
    save!
  end
  
  def delete_from_facebook!
    request = Mogli::AppRequest.new({:id => facebook_id}, Mogli::AppClient.create_and_authenticate_as_application(Facebooker2.app_id, Facebooker2.secret))
    
    request.destroy
    
    destroy
  end

  protected
  
  def schedule_data_update
    Delayed::Job.enqueue Jobs::RequestDataUpdate.new(id)
  end
  
  def process_request
    return unless data

    case data['type']
    when 'invitation'
      sender.invitations.create(
        :app_request => self,
        :receiver_id => receiver_id
      )
    when 'gift'
      sender.character.gifts.create(
        :app_request  => self, 
        :receiver_id  => receiver_id, 
        :item_id      => data['item_id']
      )
    end
  end
end
