class AddKillerToMonsters < ActiveRecord::Migration
  def self.up
    add_column :monsters, :killer_id, :integer
    
    add_column :characters, :killed_monsters_count, :integer, :default => 0
  end

  def self.down
    remove_column :monsters, :killer_id
    
    remove_column :characters, :killed_monsters_count
  end
end
