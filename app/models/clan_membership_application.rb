class ClanMembershipApplication < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
end
