class CreateHelpResults < ActiveRecord::Migration
  def self.up
    create_table :help_results do |t|
      t.integer :help_request_id
      t.integer :character_id

      t.integer :money
      t.integer :experience
      
      t.timestamps
    end
  end

  def self.down
    drop_table :help_results
  end
end
