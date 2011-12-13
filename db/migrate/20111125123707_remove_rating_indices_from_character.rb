class RemoveRatingIndicesFromCharacter < ActiveRecord::Migration
  def self.up
    remove_index :characters, :total_monsters_damage
    remove_index :characters, :total_score
  end

  def self.down
    add_index "characters", ["total_monsters_damage"], :name => "index_characters_on_total_monsters_damage"
    add_index "characters", ["total_score"], :name => "index_characters_on_total_score"
  end
end
