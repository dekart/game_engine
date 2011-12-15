class ClanMembershipApplication < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
  
  def establish_notification(status)
    character.notifications.schedule(:status_application,
      :clan_id => clan.id,
      :status  => status.to_s
    )
  end
  
  def create_clan_member!
    member = clan.clan_members.build(:character => character, :role => :participant)
    
    if clan.members_count >= Setting.i(:clan_max_size)
      false
    else
      member.save
      
      member 
    end 
  end
end
