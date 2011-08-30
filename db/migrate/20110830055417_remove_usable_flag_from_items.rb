class RemoveUsableFlagFromItems < ActiveRecord::Migration
  def self.up
    remove_column :items, :usable
  end

  def self.down
    add_column :items, :usable, :boolean
  end
end
