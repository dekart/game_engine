class RemoveTitles < ActiveRecord::Migration
  def self.up
    drop_table "titles"
    drop_table "character_titles"
  end

  def self.down
    create_table "titles", :force => true do |t|
      t.string   "name",       :limit => 100, :default => "", :null => false
      t.string   "state",      :limit => 50,  :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "character_titles", :force => true do |t|
      t.integer  "character_id", :null => false
      t.integer  "title_id",     :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  
    add_index "character_titles", ["character_id", "title_id"], :name => "index_character_titles_on_character_id_and_title_id", :unique => true
  end
end
