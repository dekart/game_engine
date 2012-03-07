class RemoveAssetsTable < ActiveRecord::Migration
  def up
    drop_table :assets
  end

  def down
    create_table "assets", :force => true do |t|
      t.string   "alias",              :limit => 200, :default => "", :null => false
      t.string   "image_file_name",                   :default => "", :null => false
      t.string   "image_content_type", :limit => 100, :default => "", :null => false
      t.integer  "image_file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "image_updated_at"
    end
  
    add_index "assets", ["alias"], :name => "index_assets_on_alias"
  end
end
