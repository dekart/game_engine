class AddCounterCacheToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :upgrade_recipes_count, :integer, :default => 0
  end

  def self.down
    remove_column :items, :upgrade_recipes_count
  end
end
