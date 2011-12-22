class ClanMembershipInvitation < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
  
  validate_on_create :validate_for_uniqueness_invitation
  
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
  
  protected
  
  def validate_for_uniqueness_invitation
    errors_add(:invitation, :not_unique) if character.clan_membership_invitations.invitation_to_join(clan)
  end
end
