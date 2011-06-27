class RemoveNewsletterTable < ActiveRecord::Migration
  def self.up
    drop_table :newsletters
  end

  def self.down
    create_table "newsletters", :force => true do |t|
      t.string   "text"
      t.string   "state",             :limit => 50, :default => "",    :null => false
      t.integer  "last_recipient_id"
      t.integer  "delivery_job_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
