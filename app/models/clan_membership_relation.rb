class ClanMembershipRelation < ActiveRecord::Base
  belongs_to :clan
  belongs_to :character
end
