class RenameTextsAddChancesToMissions < ActiveRecord::Migration
  def self.up
    rename_column :missions, :won_text, :success_text
    rename_column :missions, :lost_text, :failure_text

    add_column :missions, :success_chance, :integer, :default => 100
  end

  def self.down
    rename_column :missions, :success_text, :won_text
    rename_column :missions, :failure_text, :lost_text

    remove_column :missions, :success_chance
  end
end
