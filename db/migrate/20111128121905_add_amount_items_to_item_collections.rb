class AddAmountItemsToItemCollections < ActiveRecord::Migration
  def self.up
    add_column :item_collections, :amount_items, :string, :default => "", :null => false
  end

  def self.down
    remove_column :item_collections, :amount_items
  end
end
