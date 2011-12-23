class ClanMembershipInvitation < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
  
  validates_uniqueness_of :character_id, :scope => :clan_id
  
  def accept!
    transaction do
      destroy
      
      if clan.clan_members.create(:character => character, :role => :participant)
        clan.creator.notifications.schedule(:clan_invitation_state,
          :clan_id => clan.id,
          :character_id => character.id,
          :status  => :accepted
        )
      end
    end
  end
end
