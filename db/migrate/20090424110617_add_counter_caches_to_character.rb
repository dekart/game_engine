class AddCounterCachesToCharacter < ActiveRecord::Migration
  def self.up
    add_column :characters, :fights_won, :integer, :default => 0
    add_column :characters, :fights_lost, :integer, :default => 0
    add_column :characters, :missions_succeeded, :integer, :default => 0
    add_column :characters, :missions_completed, :integer, :default => 0
    
    add_column :characters, :relations_count, :integer, :default => 0

    Character.update_all("fights_won = (SELECT COUNT(*) FROM fights WHERE winner_id = characters.id)")
    Character.update_all("fights_lost = (SELECT COUNT(*) FROM fights WHERE (attacker_id = characters.id OR victim_id = characters.id) AND winner_id != characters.id)")
    Character.update_all("missions_succeeded = (SELECT sum(win_count) FROM ranks WHERE character_id = characters.id)")
    Character.update_all("missions_completed = (SELECT count(*) FROM ranks WHERE character_id = characters.id AND completed = 1)")

    Character.update_all("relations_count = (SELECT count(*) FROM relations WHERE source_id = characters.id)")
  end

  def self.down
    remove_column :characters, :fights_won
    remove_column :characters, :fights_lost
    remove_column :characters, :missions_succeeded
    remove_column :characters, :missions_completed
    
    remove_column :characters, :relations_count
  end
end
