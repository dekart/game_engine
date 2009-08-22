class AddSkipTutorialToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :skip_tutorial, :boolean

    User.update_all("skip_tutorial = 1")
  end

  def self.down
    remove_column :users, :skip_tutorial
  end
end
