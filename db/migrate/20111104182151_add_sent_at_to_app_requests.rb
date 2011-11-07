class AddSentAtToAppRequests < ActiveRecord::Migration
  def self.up
    change_table :app_requests do |t|
      t.datetime :sent_at
    end
  end

  def self.down
  end
end
