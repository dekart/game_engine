class CreateCreditOrders < ActiveRecord::Migration
  def self.up
    create_table :credit_orders do |t|
      t.integer :facebook_id, :limit => 8, :null => false
      
      t.integer :character_id
      t.integer :package_id
      
      t.string  :state, :limit => 30
      
      t.timestamps
      
      t.index :facebook_id
      t.index :character_id
    end
  end

  def self.down
    drop_table :credit_orders
  end
end
