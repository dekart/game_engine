class AddInstalledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :installed, :boolean, :default => true
  end
end
