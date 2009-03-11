class CreateRanks < ActiveRecord::Migration
  def self.up
    create_table :ranks do |t|
      t.integer :character_id
      t.integer :mission_id

      t.integer :win_count, :default => 0
      t.integer :defeat_count, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :ranks
  end
end
