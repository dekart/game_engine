class CreateExchanges < ActiveRecord::Migration
  def self.up
    add_column :items, :exchangeable, :boolean, :default => false
    
    create_table :exchanges do |t|
      t.integer :item_id, :null => false
      t.integer :character_id, :null => false
      
      t.string :state, :null => false
      
      t.integer :amount, :null => false, :default => 1
      t.text :text

      t.timestamps
    end
    
    add_index :exchanges, :character_id
    
    create_table :exchange_offers do |t|
      t.integer :exchange_id, :null => false
      t.integer :item_id, :null => false
      t.integer :character_id, :null => false
      
      t.string :state, :null => false
      
      t.integer :amount, :null => false, :default => 1
      
      t.timestamps
    end
    
    add_index :exchange_offers, :exchange_id
  end

  def self.down
    remove_column :items, :exchangeable
    drop_table :exchanges
    drop_table :exchange_offers
  end
end
