class RemoveLoggedEvents < ActiveRecord::Migration
  def self.up
    drop_table :logged_events
  end

  def self.down
    create_table "logged_events", :force => true do |t|
      t.string   "event_type"
      t.integer  "character_id"
      t.integer  "level"
      t.integer  "reference_id"
      t.string   "reference_type"
      t.integer  "reference_level"
      t.integer  "amount"
      t.integer  "experience"
      t.integer  "basic_money",      :limit => 8
      t.integer  "vip_money",        :limit => 8
      t.string   "string_value"
      t.integer  "int_value"
      t.datetime "occurred_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "health"
      t.integer  "energy"
      t.integer  "stamina"
      t.integer  "reference_damage"
      t.boolean  "export",                        :default => false
    end
  
    add_index "logged_events", ["event_type"], :name => "index_logged_events_on_event_type"
  end
end
