class AddUsableFlagToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :usable, :boolean
    add_column :items, :usage_limit, :integer

    add_column :inventories, :usage_count, :integer, :default => 0
  end

  def self.down
    remove_column :items, :usable
    remove_column :items, :usage_limit

    remove_column :inventories, :usage_count
  end
end
