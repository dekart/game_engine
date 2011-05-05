class AddNotifyNewUsersToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :notify_new_users, :boolean, :default => false
  end

  def self.down
    remove_column :messages, :notify_new_users
  end
end
