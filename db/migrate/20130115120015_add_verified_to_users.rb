class AddVerifiedToUsers < ActiveRecord::Migration
  def up
    add_column :users, :verified, :boolean
  end

  def down
    remove_column :users, :verified
  end
end
