class AddDefaultLevelToItems < ActiveRecord::Migration
  def self.up
    change_column :items, :level, :integer, :default => 1
  end

  def self.down
    change_column :items, :level, :integer, :default => nil
  end
end
