class AddMissingIndicesToMonsterFightsAndAppRequests < ActiveRecord::Migration
  def self.up
    remove_index :app_requests, :column => [:target_id, :target_type]
    
    add_index :app_requests, [:sender_id, :type]
    
    add_index :monster_fights, :character_id
  end

  def self.down
    add_index :app_requests, [:target_id, :target_type]
    
    remove_index :app_requests, :column => [:sender_id, :type]
    
    remove_index :monster_fights, :column => :character_id
  end
end
