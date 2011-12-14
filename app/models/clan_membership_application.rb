class ClanMembershipApplication < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
  
  def establish_notification(status)
    self.character.notifications.schedule(:status_application,
      :clan_id => self.clan.id,
      :status  => status.to_s
    )
  end
end
