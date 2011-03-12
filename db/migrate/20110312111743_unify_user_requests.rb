class UnifyUserRequests < ActiveRecord::Migration
  def self.up
    create_table :app_requests_new do |t|
      t.integer  "facebook_id",  :limit => 8,                  :null => false
      t.integer  "sender_id"
      t.integer  "receiver_id",  :limit => 8
      t.text     "data"

      t.string   "state",        :limit => 50, :default => "", :null => false
      
      t.datetime "processed_at"
      t.datetime "visited_at"
      t.datetime "accepted_at"
      
      t.string   "type",        :limit => 50, :default => "", :null => false

      t.timestamps
    end
    
    #rename_table :app_requests, :app_requests_old
    #rename_table :app_requests_new, :app_requests
  end

  def self.down
  end
end
