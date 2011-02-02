class AppRequest < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  
  serialize :data
  
  validates_presence_of :facebook_id
  
  after_create :schedule_data_update
  after_update :process_request, :if => :data_changed?
  
  def update_data!
    request = Mogli::AppRequest.find(facebook_id, Mogli::AppClient.create_and_authenticate_as_application(Facebooker2.app_id, Facebooker2.secret))
    
    self.sender = User.find_by_facebook_id(request.from.id)
    self.receiver_id = request.to.id
    self.data = JSON.parse(request.data)
    
    save!
  end
    
  protected
  
  def schedule_data_update
    Delayed::Job.enqueue Jobs::RequestDataUpdate.new(id)
  end
  
  def process_request
    return unless data

    case data['type']
    when 'invitation'
      sender.invitations.create!(:receiver_id => receiver_id)
    end
  end
end
