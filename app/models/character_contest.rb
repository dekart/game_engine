# model saves character results in particular contest
class CharacterContest < ActiveRecord::Base
  belongs_to :character
  belongs_to :contest
end