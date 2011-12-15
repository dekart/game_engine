class ClanMember < ActiveRecord::Base
  ROLE = {:creator => "creator", :participant => "participant"}
  
  belongs_to :clan, :counter_cache => :members_count
  belongs_to :character
  
  before_create :role_assignment
  
  def creator?
    role == ROLE[:creator]
  end
  
  def establish_notification(status)
    character.notifications.schedule(:status_clan,
      :clan_id => clan_id,
      :status  => status.to_s
    )
  end
  
  protected
  
  def role_assignment
    self.role = ROLE[role]
  end
  
end