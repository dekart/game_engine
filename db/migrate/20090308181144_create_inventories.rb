class CreateInventories < ActiveRecord::Migration
  def self.up
    create_table :inventories do |t|
      t.integer :character_id
      t.integer :item_id

      t.integer :amount, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :inventories
  end
end
