class AddReceiverIndexToAppRequests < ActiveRecord::Migration
  def self.up
    add_index :app_requests, [:receiver_id, :state]
  end

  def self.down
    remove_index :app_requests, :column => [:receiver_id, :state]
  end
end
