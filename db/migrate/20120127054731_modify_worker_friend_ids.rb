class ModifyWorkerFriendIds < ActiveRecord::Migration
  def self.up
    change_column :properties, :worker_friend_ids, :text
  end

  def self.down
    change_column :properties, :worker_friend_ids, :string
  end
end
