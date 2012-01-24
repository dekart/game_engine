class AddUpgradableFlagToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :upgradable, :boolean, :default => false
  end

  def self.down
    remove_column :items, :upgradable
  end
end
