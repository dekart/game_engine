class MonsterFight < ActiveRecord::Base
  belongs_to :character
  belongs_to :monster

  protected

  
end
