class AddExchangeableToItemCollections < ActiveRecord::Migration
  def up
    add_column :item_collections, :exchangeable, :boolean, :default => true
  end

  def down
    remove_column :item_collections, :exchangeable
  end
end
