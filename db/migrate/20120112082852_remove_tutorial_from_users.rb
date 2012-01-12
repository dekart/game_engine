class RemoveTutorialFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :tutorial_step
    remove_column :users, :show_tutorial
  end

  def self.down
    add_column :users, :tutorial_step, :default => ""
    add_column :users, :show_tutorial, :default => true
  end
end
