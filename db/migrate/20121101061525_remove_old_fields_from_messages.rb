class RemoveOldFieldsFromMessages < ActiveRecord::Migration
  def up
    remove_column :messages, :amount_sent
    remove_column :messages, :last_recipient_id
    remove_column :messages, :notify_new_users
  end

  def down
    add_column :messages, :amount_sent, :integer, :default => 0
    add_column :messages, :last_recipient_id, :integer
    add_column :messages, :notify_new_users, :boolean, :default => false
  end
end
