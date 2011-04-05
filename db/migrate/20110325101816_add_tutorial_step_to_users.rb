class AddTutorialStepToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tutorial_step, :string, :default => "", :limit => 50
  end

  def self.down
    remove_column :users, :tutorial_step
  end
end
