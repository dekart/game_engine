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

ActiveRecord::Schema.define(:version => 20090913151424) do

  create_table "assignments", :force => true do |t|
    t.integer  "relation_id"
    t.integer  "context_id"
    t.string   "context_type"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["context_id", "context_type"], :name => "index_assignments_on_context_id_and_context_type"
  add_index "assignments", ["relation_id"], :name => "index_assignments_on_relation_id"

  create_table "bank_operations", :force => true do |t|
    t.integer  "character_id"
    t.integer  "amount"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bank_operations", ["character_id"], :name => "index_bank_operations_on_character_id"

  create_table "characters", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "basic_money",            :default => 10
    t.integer  "vip_money",              :default => 0
    t.integer  "level",                  :default => 1
    t.integer  "experience",             :default => 0
    t.integer  "points",                 :default => 0
    t.integer  "attack",                 :default => 1
    t.integer  "defence",                :default => 1
    t.integer  "hp",                     :default => 100
    t.integer  "health",                 :default => 100
    t.integer  "ep",                     :default => 10
    t.integer  "energy",                 :default => 10
    t.text     "inventory_effects"
    t.datetime "hp_updated_at"
    t.datetime "ep_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fights_won",             :default => 0
    t.integer  "fights_lost",            :default => 0
    t.integer  "missions_succeeded",     :default => 0
    t.integer  "missions_completed",     :default => 0
    t.integer  "relations_count",        :default => 0
    t.integer  "rating",                 :default => 0
    t.integer  "bank",                   :default => 0
    t.integer  "property_income",        :default => 0
    t.datetime "basic_money_updated_at"
    t.text     "relation_effects"
  end

  add_index "characters", ["level"], :name => "index_characters_on_level"
  add_index "characters", ["rating"], :name => "index_characters_on_rating"
  add_index "characters", ["user_id"], :name => "index_characters_on_user_id"

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

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "issue_type"
    t.string   "subject"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "cause_id"
  end

  add_index "fights", ["attacker_id", "winner_id"], :name => "index_fights_on_attacker_id_and_winner_id"
  add_index "fights", ["cause_id"], :name => "index_fights_on_cause_id"
  add_index "fights", ["victim_id"], :name => "index_fights_on_victim_id"

  create_table "help_requests", :force => true do |t|
    t.integer  "character_id"
    t.integer  "mission_id"
    t.integer  "help_results_count", :default => 0
    t.integer  "money",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "help_requests", ["character_id"], :name => "index_help_requests_on_character_id"

  create_table "help_results", :force => true do |t|
    t.integer  "help_request_id"
    t.integer  "character_id"
    t.integer  "money"
    t.integer  "experience"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "help_results", ["help_request_id", "character_id"], :name => "index_help_results_on_help_request_id_and_character_id"

  create_table "inventories", :force => true do |t|
    t.integer  "character_id"
    t.integer  "item_id"
    t.string   "placement"
    t.integer  "usage_count",                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "holder_id"
    t.string   "holder_type",  :limit => 50
  end

  add_index "inventories", ["character_id", "placement"], :name => "index_inventories_on_character_id_and_placement"

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id", :limit => 8
    t.boolean  "accepted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["receiver_id", "accepted"], :name => "index_invitations_on_receiver_id_and_accepted"
  add_index "invitations", ["sender_id"], :name => "index_invitations_on_sender_id"

  create_table "item_groups", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display_in_shop", :default => true
  end

  create_table "items", :force => true do |t|
    t.string   "availability",       :limit => 30, :default => "shop"
    t.integer  "level"
    t.integer  "basic_price"
    t.integer  "vip_price"
    t.string   "name"
    t.string   "description"
    t.string   "placements"
    t.text     "effects"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.boolean  "usable"
    t.integer  "usage_limit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_group_id"
    t.boolean  "can_be_sold",                      :default => true
  end

  add_index "items", ["item_group_id"], :name => "index_items_on_item_group_id"

  create_table "mission_groups", :force => true do |t|
    t.string   "name"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "missions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "success_text"
    t.text     "failure_text"
    t.text     "complete_text"
    t.integer  "win_amount"
    t.integer  "success_chance",     :default => 100
    t.string   "title"
    t.integer  "ep_cost"
    t.integer  "experience"
    t.integer  "money_min"
    t.integer  "money_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "requirements"
    t.text     "payouts"
    t.integer  "mission_group_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.integer  "parent_mission_id"
  end

  create_table "newsletters", :force => true do |t|
    t.string   "text"
    t.string   "workflow_state",    :limit => 20
    t.integer  "last_recipient_id"
    t.integer  "delivery_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promotion_receipts", :force => true do |t|
    t.integer  "promotion_id"
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promotions", :force => true do |t|
    t.text     "text"
    t.text     "payouts"
    t.datetime "valid_till"
    t.integer  "promotion_receipts_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "forwardable"
  end

  create_table "properties", :force => true do |t|
    t.integer  "property_type_id"
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",           :default => 1
  end

  add_index "properties", ["character_id"], :name => "index_properties_on_character_id"

  create_table "property_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "availability",       :limit => 30, :default => "shop"
    t.integer  "level"
    t.integer  "basic_price"
    t.integer  "vip_price"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.integer  "income"
    t.text     "requirements"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ranks", :force => true do |t|
    t.integer  "character_id"
    t.integer  "mission_id"
    t.integer  "win_count",    :default => 0
    t.boolean  "completed",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ranks", ["character_id", "mission_id"], :name => "index_ranks_on_character_id_and_mission_id"

  create_table "relations", :force => true do |t|
    t.integer  "source_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "inventory_effects"
    t.string   "type"
    t.string   "name"
  end

  add_index "relations", ["source_id", "target_id"], :name => "index_relations_on_source_id_and_target_id"

  create_table "stylesheets", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.boolean  "current"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_options", :force => true do |t|
    t.integer  "survey_id"
    t.string   "answer"
    t.integer  "survey_results_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_results", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_id"
    t.integer  "survey_option_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", :force => true do |t|
    t.string   "question"
    t.string   "workflow_state"
    t.integer  "survey_results_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tips", :force => true do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "translations", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "facebook_id",            :limit => 8
    t.boolean  "show_next_steps",                     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_fan_specials",                   :default => true
    t.boolean  "show_bookmark",                       :default => true
    t.datetime "invite_page_visited_at"
    t.boolean  "show_tips",                           :default => true
    t.boolean  "skip_tutorial"
  end

  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"

end
