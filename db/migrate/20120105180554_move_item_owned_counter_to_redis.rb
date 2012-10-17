class MoveItemOwnedCounterToRedis < ActiveRecord::Migration
  class Inventory < ActiveRecord::Base
    set_table_name :inventories
  end

  def self.up
    change_table :items do |t|
      t.remove  :owned
      t.remove  :limit
    end

    Item.reset_column_information

    puts "Updating owned item counters..."

    Item.find_each do |item|
      item.increment_owned( Inventory.count(:conditions => {:item_id => item.id}) )
    end

    puts "Done!"
  end

  def self.down
    change_table :items do |t|
      t.integer  :owned, :default => 0
      t.integer  :limit
    end
  end
end
