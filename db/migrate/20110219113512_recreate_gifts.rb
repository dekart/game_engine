class RecreateGifts < ActiveRecord::Migration
  def self.up
    create_table :gifts_new do |t|
      t.integer :sender_id
      t.column  :receiver_id, :bigint
      
      t.integer :item_id
      
      t.string  :state, :limit => 50, :default => "", :null => false
    end
    
    Rake::Task['app:maintenance:update_gift_storage_schema'].execute
    
    drop_table :gifts
    drop_table :gift_receipts
    
    rename_table :gifts_new, :gifts
  end

  def self.down
  end
end
