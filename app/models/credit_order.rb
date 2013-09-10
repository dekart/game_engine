class CreditOrder < ActiveRecord::Base
  belongs_to :character
  belongs_to :package, :class_name => 'CreditPackage'

  state_machine :initial => :initiated do
    state :initiated
    state :completed
    state :failed

    event :complete do
      transition :initiated => :completed
    end

    event :mark_failed do
      transition :initiated => :failed
    end

    after_transition :initiated => :completed, :do => :deposit_vip_money
  end

  validates_presence_of   :facebook_id
  validates_uniqueness_of :facebook_id

  def check_completion_status
    return if completed?

    data = Facepalm::Config.default.api_client.get_object(facebook_id)

    time, character_id, package_id = data["request_id"].split(':')

    self.character  ||= Character.find(character_id)
    self.package_id ||= package_id

    if data["actions"].find{|a| a["type"] == "charge" and a["status"] == "completed"}
      complete!
    end
  end


  protected

  def deposit_vip_money
    character.charge!(0, - package.vip_money, :credits)
    character.user.update_attribute(:paying, true)
  end
end
