class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.string :name, :limit => 100, :default => "", :null => false
      t.text :description, :default => "", :null => false
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :duration_time, :default => 7
      
      t.string :state, :limit => 50,  :default => "",   :null => false
      
      t.string :image_file_name, :default => "",   :null => false
      t.string :image_content_type, :limit => 100, :default => "",   :null => false
      t.integer :image_file_size

      t.timestamps
    end
    
    create_table :character_contests do |t|
      t.integer  :character_id, :null => false
      t.integer  :contest_id,   :null => false
      
      t.integer  :current_points, :default => 0
      t.integer  :previous_points, :default => 0
      t.datetime :previous_points_updated_at
      
      t.timestamps
    end
    
    add_index :character_contests, :current_points
    
    add_index :character_contests, :character_id
    add_index :character_contests, :contest_id
    add_index :character_contests, [:character_id, :contest_id]
  end

  def self.down
    drop_table :character_contests
    drop_table :contests
  end
end
