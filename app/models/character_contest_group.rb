class CharacterContestGroup < ActiveRecord::Base
  belongs_to :character
  belongs_to :contest_group
end