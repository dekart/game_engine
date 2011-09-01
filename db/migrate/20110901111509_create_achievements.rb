class CreateAchievements < ActiveRecord::Migration
  def self.up
    create_table :achievement_types do |t|
      t.string  :name,       :limit => 250,  :default => "", :null => false
      t.string  :description, :limit => 1024, :default => "", :null => false

      t.string   "image_file_name",                   :default => "", :null => false
      t.string   "image_content_type", :limit => 100, :default => "", :null => false
      t.integer  "image_file_size"
      t.datetime "image_updated_at"

      t.string  :key
      t.integer :value

      t.text    :payouts
      
      t.string  :state,       :limit => 50,   :default => "", :null => false
      
      t.timestamps
    end

    create_table :achievements do |t|
      t.integer :character_id
      t.integer :achievement_type_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :achievement_types
    drop_table :achievements
  end
end
