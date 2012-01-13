class ClanMembershipApplication < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
  
  after_create :shedule_notification_for_creator
  
  def approve!
    if clan.members_count >= Setting.i(:clan_max_size)
      false
    else
      member = clan.clan_members.build(:character => character, :role => :participant)
    
      transaction do
        if member.save
          schedule_notification(:accepted)
          
          character.clan_membership_invitations.invitation_to_join(clan).try(:destroy)
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
  
  def shedule_notification_for_creator
    clan.creator.notifications.schedule(:clan_application_state,
      :clan_id => clan_id,
      :applicant_id  => character_id,
      :status  => "asked"
    )
  end
end
