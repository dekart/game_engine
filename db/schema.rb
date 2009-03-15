# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090314190007) do

  create_table "characters", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "money",      :default => 100
    t.integer  "level",      :default => 1
    t.integer  "experience", :default => 0
    t.integer  "points",     :default => 0
    t.integer  "attack",     :default => 1
    t.integer  "defence",    :default => 1
    t.integer  "hp",         :default => 100
    t.integer  "health",     :default => 100
    t.integer  "ep",         :default => 10
    t.integer  "energy",     :default => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facebook_templates", :force => true do |t|
    t.string "template_name", :null => false
    t.string "content_hash",  :null => false
    t.string "bundle_id"
  end

  add_index "facebook_templates", ["template_name"], :name => "index_facebook_templates_on_template_name", :unique => true

  create_table "fights", :force => true do |t|
    t.integer  "attacker_id"
    t.integer  "victim_id"
    t.integer  "winner_id"
    t.integer  "attacker_hp_loss"
    t.integer  "victim_hp_loss"
    t.integer  "experience"
    t.integer  "money"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventories", :force => true do |t|
    t.integer  "character_id"
    t.integer  "item_id"
    t.integer  "amount",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "level"
    t.integer  "price"
    t.string   "name"
    t.string   "description"
    t.integer  "attack"
    t.integer  "defence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "missions", :force => true do |t|
    t.integer  "level"
    t.string   "name"
    t.string   "description"
    t.string   "won_text"
    t.string   "lost_text"
    t.integer  "win_amount"
    t.string   "winner_title"
    t.integer  "ep_cost"
    t.integer  "experience"
    t.integer  "money_min"
    t.integer  "money_max"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ranks", :force => true do |t|
    t.integer  "character_id"
    t.integer  "mission_id"
    t.integer  "win_count",    :default => 0
    t.integer  "defeat_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "facebook_id",     :limit => 8
    t.boolean  "show_next_steps",              :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"

end
