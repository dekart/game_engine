class RecreateGifts < ActiveRecord::Migration
  def self.up
    create_table :gifts_new do |t|
      t.integer :sender_id
      t.column  :receiver_id, :bigint
      
      t.integer :item_id
      
      t.string  :state, :limit => 50, :default => "", :null => false
      
      t.datetime :accepted_at
      
      t.timestamps
    end
    
    Rake::Task['app:maintenance:update_gift_storage_schema'].execute
    
    drop_table :gifts
    drop_table :gift_receipts
    
    rename_table :gifts_new, :gifts
  end

  def self.down
    drop_table :gifts
    
    create_table "gift_receipts" do |t|
      t.integer  "gift_id"
      t.integer  "character_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "accepted",                  :default => false, :null => false
      t.integer  "facebook_id",  :limit => 8
    end

    add_index "gift_receipts", ["character_id", "gift_id"], :name => "index_gift_receipts_on_character_id_and_gift_id"

    create_table "gifts" do |t|
      t.integer  "character_id"
      t.integer  "item_id"
      t.text     "recipients"
      t.integer  "recipients_count"
      t.integer  "receipts_count"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "gifts", ["character_id"], :name => "index_gifts_on_character_id"
  end
end
