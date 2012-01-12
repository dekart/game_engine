class RemoveBosses < ActiveRecord::Migration
  def self.up
    drop_table :bosses
    drop_table :boss_fights
  end

  def self.down
    create_table "boss_fights", :force => true do |t|
      t.integer  "boss_id"
      t.integer  "character_id"
      t.integer  "health"
      t.datetime "expire_at"
      t.string   "state",        :limit => 50, :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "lock_version",               :default => 0
    end
  
    add_index "boss_fights", ["character_id", "boss_id"], :name => "index_boss_fights_on_character_id_and_boss_id"
  
    create_table "bosses", :force => true do |t|
      t.integer  "mission_group_id"
      t.string   "name",               :limit => 100, :default => "", :null => false
      t.text     "description"
      t.integer  "health"
      t.integer  "attack"
      t.integer  "defence"
      t.integer  "ep_cost"
      t.integer  "experience"
      t.text     "requirements"
      t.text     "payouts"
      t.string   "image_file_name",                   :default => "", :null => false
      t.string   "image_content_type", :limit => 100, :default => "", :null => false
      t.integer  "image_file_size"
      t.integer  "time_limit",                        :default => 60
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "repeatable"
      t.string   "state",              :limit => 50,  :default => "", :null => false
      t.datetime "image_updated_at"
    end
  
    add_index "bosses", ["mission_group_id"], :name => "index_bosses_on_mission_group_id"
  end
end
