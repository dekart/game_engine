class ClanMember < ActiveRecord::Base
  ROLE = {:creator => "creator", :participant => "participant"}
  
  belongs_to :clan, :counter_cache => :members_count
  belongs_to :character
  
  before_create :role_assignment, :removed_from_other_clan
  
  def creator?
    role == ROLE[:creator]
  end
  
  def delete!
    transaction do
      destroy
      
      schedule_notification(:excluded)
    end
  end
  
  protected
  
  def schedule_notification(status)
    character.notifications.schedule(:status_clan,
      :clan_id => clan_id,
      :status  => status.to_s
    )
  end
  
  def role_assignment
    self.role = ROLE[role]
  end
  
  def removed_from_other_clan
    character.clan_member.try(:destroy)
  end
  
end