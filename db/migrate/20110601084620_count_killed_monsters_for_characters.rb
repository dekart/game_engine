class CountKilledMonstersForCharacters < ActiveRecord::Migration
  def self.up
    killed_monsters_count = Monster.count(:group => :character_id)
    
    killed_monsters_count.each_pair do |character_id, count|
      Character.update_all("killed_monsters_count = #{count}", :id => character_id)
    end
  end

  def self.down
  end
end
