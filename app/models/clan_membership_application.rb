class ClanMembershipApplication < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
  
  def create_clan_member!
    if clan.members_count >= Setting.i(:clan_max_size)
      false
    else
      member = clan.clan_members.build(:character => character, :role => :participant)
    
      transaction do
        if member.save
          character.clan_membership_applications.destroy_all
      
          schedule_notification(:accepted)
        end
        
        member
      end   
    end 
  end
  
  def reject_by_creator!
    transaction do
      destroy
      
      schedule_notification(:rejected)
    end
  end
  
  protected
  
  def schedule_notification(status)
    character.notifications.schedule(:clan_application_state,
      :clan_id => clan.id,
      :status  => status.to_s
    )
  end
end