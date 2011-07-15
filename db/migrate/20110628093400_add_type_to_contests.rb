class AddTypeToContests < ActiveRecord::Migration
  def self.up
    add_column :contests, :points_type, :string, :default => ""
  end

  def self.down
    remove_column :contests, :points_type
  end
end
