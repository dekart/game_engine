class AddTotalMonstersDamageToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :total_monsters_damage, :integer, :default => 0
    
    add_index :characters, :total_monsters_damage
  end

  def self.down
    remove_column :characters, :total_monsters_damage
  end
end
