class CreatePersonalDiscounts < ActiveRecord::Migration
  def self.up
    create_table :personal_discounts do |t|
      t.integer   :character_id
      t.integer   :item_id
      
      t.integer   :price
      
      t.datetime  :available_till
      
      t.string    :state, :limit => 50, :default => "", :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :personal_discounts
  end
end
