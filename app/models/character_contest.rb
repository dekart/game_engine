class CharacterContest < ActiveRecord::Base
  belongs_to :character
  belongs_to :contest
end