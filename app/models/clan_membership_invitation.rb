class ClanMembershipInvitation < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
end
