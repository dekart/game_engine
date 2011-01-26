class CreateMissionHelpResults < ActiveRecord::Migration
  def self.up
    create_table :mission_help_results do |t|
      t.integer :character_id
      t.integer :requester_id
      t.integer :mission_id
      
      t.integer :money
      t.integer :experience
      
      t.timestamps
    end
    
    add_index :mission_help_results, [:character_id, :requester_id]
  end

  def self.down
    drop_table :mission_help_results
  end
end
