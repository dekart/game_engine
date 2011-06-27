class AddLevelToItemCollections < ActiveRecord::Migration
  def self.up
    add_column :item_collections, :level, :integer, :default => 1
  end

  def self.down
    remove_column :item_collections, :level
  end
end
