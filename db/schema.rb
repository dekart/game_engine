# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130207092611) do

  create_table "achievement_types", :force => true do |t|
    t.string   "name",               :limit => 250,  :default => "", :null => false
    t.string   "description",        :limit => 1024, :default => "", :null => false
    t.string   "image_file_name",                    :default => "", :null => false
    t.string   "image_content_type", :limit => 100,  :default => "", :null => false
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "key"
    t.integer  "value"
    t.text     "payouts"
    t.string   "state",              :limit => 50,   :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "achievements", :force => true do |t|
    t.integer  "character_id"
    t.integer  "achievement_type_id"
    t.boolean  "collected"
    t.datetime "collected_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "achievements", ["character_id"], :name => "index_achievements_on_character_id"

  create_table "app_requests", :force => true do |t|
    t.integer  "facebook_id",  :limit => 8,                  :null => false
    t.integer  "sender_id"
    t.integer  "receiver_id",  :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",        :limit => 50, :default => "", :null => false
    t.datetime "processed_at"
    t.datetime "accepted_at"
    t.datetime "visited_at"
    t.string   "type",         :limit => 50, :default => "", :null => false
    t.datetime "expired_at"
    t.integer  "target_id"
    t.string   "target_type",  :limit => 50
    t.datetime "sent_at"
  end

  add_index "app_requests", ["facebook_id"], :name => "index_app_requests_on_facebook_id"
  add_index "app_requests", ["receiver_id", "state"], :name => "index_app_requests_on_receiver_id_and_state"
  add_index "app_requests", ["sender_id", "type"], :name => "index_app_requests_on_sender_id_and_type"
  add_index "app_requests", ["target_id", "target_type"], :name => "index_app_requests_on_target_id_and_target_type"

  create_table "assignments", :force => true do |t|
    t.integer  "relation_id"
    t.integer  "context_id",                                 :null => false
    t.string   "context_type", :limit => 50, :default => "", :null => false
    t.string   "role",         :limit => 50, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["context_id", "context_type"], :name => "index_assignments_on_context_id_and_context_type"
  add_index "assignments", ["relation_id"], :name => "index_assignments_on_relation_id"

  create_table "bank_operations", :force => true do |t|
    t.integer  "character_id",                               :null => false
    t.integer  "amount",       :limit => 8
    t.string   "type",         :limit => 50, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bank_operations", ["character_id"], :name => "index_bank_operations_on_character_id"

  create_table "character_contest_groups", :force => true do |t|
    t.integer  "character_id",                        :null => false
    t.integer  "points",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_group_id",                    :null => false
    t.boolean  "reward_collected", :default => false
  end

  add_index "character_contest_groups", ["character_id"], :name => "index_character_contests_on_character_id"
  add_index "character_contest_groups", ["character_id"], :name => "index_character_contests_on_character_id_and_contest_id"
  add_index "character_contest_groups", ["points"], :name => "index_character_contests_on_points"

  create_table "character_equipment", :force => true do |t|
    t.integer  "character_id"
    t.text     "placements"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "inventories"
  end

  add_index "character_equipment", ["character_id"], :name => "index_character_equipment_on_character_id"

  create_table "character_types", :force => true do |t|
    t.string   "name",                  :limit => 100, :default => "",  :null => false
    t.text     "description"
    t.integer  "basic_money",                          :default => 10
    t.integer  "vip_money",                            :default => 0
    t.integer  "attack",                               :default => 1
    t.integer  "defence",                              :default => 1
    t.integer  "health",                               :default => 100
    t.integer  "energy",                               :default => 10
    t.string   "image_file_name",                      :default => "",  :null => false
    t.string   "image_content_type",    :limit => 100, :default => "",  :null => false
    t.integer  "image_file_size"
    t.string   "state",                 :limit => 50,  :default => "",  :null => false
    t.integer  "characters_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stamina",                              :default => 10
    t.integer  "health_restore_bonus",                 :default => 0
    t.integer  "energy_restore_bonus",                 :default => 0
    t.integer  "stamina_restore_bonus",                :default => 0
    t.integer  "income_period_bonus",                  :default => 0
    t.integer  "points",                               :default => 0
    t.integer  "equipment_slots",                      :default => 5
    t.datetime "image_updated_at"
  end

  create_table "characters", :force => true do |t|
    t.integer  "user_id",                                                                           :null => false
    t.string   "name",                     :limit => 100,        :default => ""
    t.integer  "basic_money",                                    :default => 0
    t.integer  "vip_money",                                      :default => 0
    t.integer  "level",                                          :default => 1
    t.integer  "experience",                                     :default => 0
    t.integer  "points",                                         :default => 0
    t.integer  "attack",                                         :default => 0
    t.integer  "defence",                                        :default => 0
    t.integer  "hp",                                             :default => 100
    t.integer  "health",                                         :default => 0
    t.integer  "ep",                                             :default => 10
    t.integer  "energy",                                         :default => 0
    t.text     "inventory_effects"
    t.datetime "hp_updated_at"
    t.datetime "ep_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fights_won",                                     :default => 0
    t.integer  "fights_lost",                                    :default => 0
    t.integer  "missions_succeeded",                             :default => 0
    t.integer  "missions_completed",                             :default => 0
    t.integer  "relations_count",                                :default => 0
    t.integer  "bank",                     :limit => 8,          :default => 0
    t.datetime "basic_money_updated_at"
    t.text     "relation_effects"
    t.integer  "current_mission_group_id"
    t.integer  "character_type_id"
    t.integer  "stamina",                                        :default => 0
    t.integer  "sp",                                             :default => 10
    t.datetime "sp_updated_at"
    t.text     "placements_old",           :limit => 2147483647
    t.integer  "total_money",              :limit => 8,          :default => 0
    t.datetime "hospital_used_at",                               :default => '1970-01-01 05:00:00'
    t.integer  "missions_mastered",                              :default => 0
    t.integer  "lock_version",                                   :default => 0
    t.datetime "fighting_available_at",                          :default => '1970-01-01 05:00:00'
    t.integer  "killed_monsters_count",                          :default => 0
    t.integer  "total_monsters_damage",                          :default => 0
    t.text     "active_boosts"
    t.integer  "achievement_points",                             :default => 0
    t.boolean  "exclude_from_fights",                            :default => false
    t.boolean  "restrict_fighting",                              :default => false
    t.boolean  "restrict_market",                                :default => false
    t.boolean  "restrict_talking",                               :default => false
    t.datetime "excluded_from_fights_at",                        :default => '1970-01-01 00:00:00', :null => false
  end

  add_index "characters", ["level", "fighting_available_at", "exclude_from_fights", "restrict_fighting"], :name => "by_level_and_fighting_time_and_flags"
  add_index "characters", ["user_id"], :name => "index_characters_on_user_id"

  create_table "clan_members", :force => true do |t|
    t.integer  "character_id"
    t.integer  "clan_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clan_membership_applications", :force => true do |t|
    t.integer  "clan_id"
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clan_membership_invitations", :force => true do |t|
    t.integer  "clan_id"
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clans", :force => true do |t|
    t.string   "name",               :limit => 100
    t.text     "description"
    t.string   "image_file_name",                   :default => "", :null => false
    t.string   "image_file_content", :limit => 100
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "members_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "complaints", :force => true do |t|
    t.string   "cause"
    t.text     "description"
    t.integer  "owner_id"
    t.integer  "offender_id"
    t.string   "state",       :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contest_groups", :force => true do |t|
    t.integer  "contest_id"
    t.integer  "max_character_level"
    t.text     "payouts"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contest_groups", ["contest_id"], :name => "index_contest_groups_on_contest_id"

  create_table "contests", :force => true do |t|
    t.string   "name",                       :limit => 100, :default => "",    :null => false
    t.text     "description_when_finished",                                    :null => false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "duration_time",                             :default => 7
    t.string   "state",                      :limit => 50,  :default => "",    :null => false
    t.string   "image_file_name",                           :default => "",    :null => false
    t.string   "image_content_type",         :limit => 100, :default => "",    :null => false
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "points_type",                               :default => ""
    t.text     "description_when_started"
    t.text     "description_before_started"
    t.boolean  "finish_notification_sent",                  :default => false
  end

  create_table "credit_orders", :force => true do |t|
    t.integer  "facebook_id",  :limit => 8,  :null => false
    t.integer  "character_id"
    t.integer  "package_id"
    t.string   "state",        :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_orders", ["facebook_id"], :name => "index_credit_orders_on_facebook_id"

  create_table "credit_packages", :force => true do |t|
    t.integer  "vip_money"
    t.integer  "price"
    t.boolean  "default"
    t.string   "image_file_name",                   :default => "", :null => false
    t.string   "image_content_type", :limit => 100, :default => "", :null => false
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "state",              :limit => 30
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
    t.string   "queue"
  end

  create_table "exchange_offers", :force => true do |t|
    t.integer  "exchange_id",                 :null => false
    t.integer  "item_id",                     :null => false
    t.integer  "character_id",                :null => false
    t.string   "state",                       :null => false
    t.integer  "amount",       :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exchange_offers", ["exchange_id"], :name => "index_exchange_offers_on_exchange_id"

  create_table "exchanges", :force => true do |t|
    t.integer  "item_id",                     :null => false
    t.integer  "character_id",                :null => false
    t.string   "state",                       :null => false
    t.integer  "amount",       :default => 1, :null => false
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exchanges", ["character_id"], :name => "index_exchanges_on_character_id"

  create_table "fights", :force => true do |t|
    t.integer  "attacker_id",                                    :null => false
    t.integer  "victim_id",                                      :null => false
    t.integer  "winner_id"
    t.integer  "attacker_hp_loss"
    t.integer  "victim_hp_loss"
    t.integer  "experience"
    t.integer  "winner_money"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cause_id"
    t.string   "cause_type",       :limit => 50, :default => "", :null => false
    t.integer  "loser_money"
  end

  add_index "fights", ["attacker_id", "winner_id"], :name => "index_fights_on_attacker_id_and_winner_id"
  add_index "fights", ["cause_id"], :name => "index_fights_on_cause_id"
  add_index "fights", ["victim_id"], :name => "index_fights_on_victim_id"

  create_table "global_payouts", :force => true do |t|
    t.string   "name",       :limit => 100, :default => "", :null => false
    t.string   "alias",      :limit => 70,  :default => "", :null => false
    t.text     "payouts"
    t.string   "state",      :limit => 50,  :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "help_pages", :force => true do |t|
    t.string   "alias",             :limit => 100, :default => "", :null => false
    t.string   "name",              :limit => 100, :default => "", :null => false
    t.text     "content"
    t.text     "content_processed"
    t.string   "state",             :limit => 50,  :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "help_pages", ["alias"], :name => "index_help_pages_on_alias"

  create_table "hit_listings", :force => true do |t|
    t.integer  "client_id",                      :null => false
    t.integer  "victim_id",                      :null => false
    t.integer  "executor_id"
    t.integer  "reward"
    t.boolean  "completed",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hit_listings", ["client_id"], :name => "index_hit_listings_on_client_id"

  create_table "inventories", :force => true do |t|
    t.integer  "character_id",                                    :null => false
    t.integer  "item_id"
    t.integer  "usage_count",                      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "holder_id"
    t.string   "holder_type",        :limit => 50
    t.integer  "amount",                           :default => 0
    t.integer  "equipped",                         :default => 0
    t.integer  "market_items_count",               :default => 0
  end

  add_index "inventories", ["character_id"], :name => "index_inventories_on_character_id_and_placement"

  create_table "inventory_states", :force => true do |t|
    t.integer "character_id"
    t.binary  "inventory",    :limit => 16777215
  end

  create_table "item_collection_ranks", :force => true do |t|
    t.integer  "character_id",                    :null => false
    t.integer  "collection_id",                   :null => false
    t.integer  "collection_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "item_collection_ranks", ["character_id", "collection_id"], :name => "index_collection_ranks_on_character_id_and_collection_id"

  create_table "item_collections", :force => true do |t|
    t.string   "name",         :limit => 100, :default => "", :null => false
    t.string   "item_ids",                    :default => "", :null => false
    t.text     "payouts"
    t.string   "state",        :limit => 50,  :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",                       :default => 1
    t.string   "amount_items",                :default => "", :null => false
  end

  create_table "item_groups", :force => true do |t|
    t.string   "name",            :limit => 100, :default => "",   :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display_in_shop",                :default => true
    t.string   "state",           :limit => 50,  :default => "",   :null => false
  end

  create_table "item_sets", :force => true do |t|
    t.string   "name"
    t.string   "item_ids",   :limit => 2048
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "availability",            :limit => 30,  :default => "shop", :null => false
    t.integer  "level",                                  :default => 1
    t.integer  "basic_price",             :limit => 8
    t.integer  "vip_price"
    t.string   "name",                    :limit => 100, :default => "",     :null => false
    t.string   "description",                            :default => "",     :null => false
    t.string   "placements",                             :default => "",     :null => false
    t.string   "image_file_name",                        :default => "",     :null => false
    t.string   "image_content_type",      :limit => 100, :default => "",     :null => false
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_group_id",                                              :null => false
    t.boolean  "can_be_sold",                            :default => true
    t.datetime "available_till"
    t.string   "plural_name",             :limit => 100, :default => "",     :null => false
    t.string   "state",                   :limit => 50,  :default => "",     :null => false
    t.boolean  "equippable",                             :default => false
    t.text     "payouts"
    t.string   "use_button_label",        :limit => 50,  :default => "",     :null => false
    t.string   "use_message",                            :default => "",     :null => false
    t.boolean  "can_be_sold_on_market"
    t.datetime "image_updated_at"
    t.integer  "package_size"
    t.integer  "max_vip_price_in_market"
    t.string   "boost_type",              :limit => 50,  :default => "",     :null => false
    t.integer  "original_vip_price"
    t.boolean  "exchangeable",                           :default => false
    t.text     "effects"
    t.string   "alias",                                  :default => "",     :null => false
  end

  add_index "items", ["item_group_id"], :name => "index_items_on_item_group_id"

  create_table "market_items", :force => true do |t|
    t.integer  "character_id",                :null => false
    t.integer  "item_id",                     :null => false
    t.integer  "amount",       :default => 1
    t.integer  "basic_price"
    t.integer  "vip_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "market_items", ["character_id"], :name => "index_market_items_on_character_id"

  create_table "messages", :force => true do |t|
    t.text     "content"
    t.integer  "min_level"
    t.string   "state",      :limit => 50, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mission_group_ranks", :force => true do |t|
    t.integer "character_id",     :null => false
    t.integer "mission_group_id", :null => false
    t.boolean "completed"
  end

  add_index "mission_group_ranks", ["character_id", "mission_group_id"], :name => "index_mission_group_ranks_on_character_id_and_mission_group_id"

  create_table "mission_groups", :force => true do |t|
    t.string   "name",               :limit => 100, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "payouts"
    t.string   "image_file_name",                   :default => "", :null => false
    t.string   "image_content_type", :limit => 100, :default => "", :null => false
    t.integer  "image_file_size"
    t.string   "state",              :limit => 50,  :default => "", :null => false
    t.text     "requirements"
    t.boolean  "hide_unsatisfied"
    t.integer  "position"
    t.datetime "image_updated_at"
  end

  create_table "mission_help_results", :force => true do |t|
    t.integer  "character_id",                    :null => false
    t.integer  "requester_id",                    :null => false
    t.integer  "mission_id"
    t.integer  "basic_money"
    t.integer  "experience"
    t.boolean  "collected",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mission_help_results", ["character_id", "requester_id"], :name => "index_mission_help_results_on_character_id_and_requester_id"
  add_index "mission_help_results", ["requester_id", "collected"], :name => "index_mission_help_results_on_requester_id_and_collected"

  create_table "mission_level_ranks", :force => true do |t|
    t.integer  "character_id",                    :null => false
    t.integer  "mission_id",                      :null => false
    t.integer  "level_id",                        :null => false
    t.integer  "progress",     :default => 0
    t.boolean  "completed",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mission_level_ranks", ["character_id", "level_id"], :name => "index_mission_level_ranks_on_character_id_and_level_id", :unique => true
  add_index "mission_level_ranks", ["character_id", "mission_id"], :name => "index_mission_level_ranks_on_character_id_and_mission_id"

  create_table "mission_levels", :force => true do |t|
    t.integer  "mission_id",                    :null => false
    t.integer  "position"
    t.integer  "win_amount"
    t.integer  "chance",       :default => 100
    t.integer  "energy"
    t.integer  "experience"
    t.integer  "money_min"
    t.integer  "money_max"
    t.text     "payouts"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "requirements"
  end

  add_index "mission_levels", ["mission_id"], :name => "index_mission_levels_on_mission_id"

  create_table "mission_ranks", :force => true do |t|
    t.integer  "character_id",                        :null => false
    t.integer  "mission_id",                          :null => false
    t.boolean  "completed",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mission_group_id"
  end

  add_index "mission_ranks", ["character_id", "mission_id"], :name => "index_mission_ranks_on_character_id_and_mission_id", :unique => true

  create_table "mission_states", :force => true do |t|
    t.integer "character_id"
    t.integer "current_group_id"
    t.binary  "progress",         :limit => 16777215
  end

  create_table "missions", :force => true do |t|
    t.string   "name",                              :default => "", :null => false
    t.text     "description"
    t.text     "success_text"
    t.text     "failure_text"
    t.text     "complete_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "requirements"
    t.text     "payouts"
    t.integer  "mission_group_id",                                  :null => false
    t.string   "image_file_name",                   :default => "", :null => false
    t.string   "image_content_type", :limit => 100, :default => "", :null => false
    t.integer  "image_file_size"
    t.integer  "parent_mission_id"
    t.boolean  "repeatable"
    t.string   "state",              :limit => 50,  :default => "", :null => false
    t.integer  "levels_count",                      :default => 0
    t.integer  "position"
    t.datetime "image_updated_at"
    t.string   "button_label",                      :default => "", :null => false
    t.boolean  "hide_unsatisfied"
  end

  add_index "missions", ["mission_group_id"], :name => "index_missions_on_mission_group_id"

  create_table "monster_fights", :force => true do |t|
    t.integer  "character_id",                          :null => false
    t.integer  "monster_id",                            :null => false
    t.integer  "damage",                 :default => 0
    t.boolean  "reward_collected"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "accepted_invites_count", :default => 0
  end

  add_index "monster_fights", ["character_id"], :name => "index_monster_fights_on_character_id"
  add_index "monster_fights", ["monster_id", "character_id"], :name => "index_monster_fights_on_monster_id_and_character_id"

  create_table "monster_types", :force => true do |t|
    t.integer  "level",                                       :default => 1
    t.string   "name",                         :limit => 100, :default => "",   :null => false
    t.text     "description"
    t.integer  "health"
    t.integer  "minimum_damage"
    t.integer  "maximum_damage"
    t.integer  "minimum_response"
    t.integer  "maximum_response"
    t.integer  "experience"
    t.integer  "money"
    t.text     "requirements"
    t.text     "payouts"
    t.string   "image_file_name",                             :default => "",   :null => false
    t.string   "image_content_type",           :limit => 100, :default => "",   :null => false
    t.integer  "image_file_size"
    t.integer  "fight_time",                                  :default => 12
    t.string   "state",                        :limit => 50,  :default => "",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "available_for_friends_invite",                :default => true
    t.integer  "maximum_reward_collectors"
    t.boolean  "power_attack_enabled",                        :default => true
    t.text     "effects"
    t.integer  "respawn_time",                                :default => 24
    t.integer  "reward_time",                                 :default => 24
  end

  create_table "monsters", :force => true do |t|
    t.integer  "character_id",                                  :null => false
    t.integer  "monster_type_id",                               :null => false
    t.integer  "hp"
    t.string   "state",           :limit => 50, :default => "", :null => false
    t.datetime "expire_at"
    t.datetime "defeated_at"
    t.integer  "lock_version",                  :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "killer_id"
  end

  add_index "monsters", ["defeated_at", "expire_at"], :name => "index_monsters_on_defeated_at_and_expire_at"

  create_table "news", :force => true do |t|
    t.string   "type",         :limit => 100, :default => "", :null => false
    t.integer  "character_id",                                :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news", ["character_id"], :name => "index_news_on_character_id"

  create_table "personal_discounts", :force => true do |t|
    t.integer  "character_id"
    t.integer  "item_id"
    t.integer  "price"
    t.datetime "available_till"
    t.string   "state",          :limit => 50, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "personal_discounts", ["character_id", "available_till"], :name => "index_personal_discounts_on_character_id_and_available_till"

  create_table "pictures", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type",         :limit => 100, :default => ""
    t.string   "style"
    t.string   "image_file_name",                   :default => "", :null => false
    t.string   "image_content_type", :limit => 100, :default => "", :null => false
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promotion_receipts", :force => true do |t|
    t.integer  "promotion_id", :null => false
    t.integer  "character_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotion_receipts", ["character_id", "promotion_id"], :name => "index_promotion_receipts_on_character_id_and_promotion_id"

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
    t.integer  "property_type_id",                 :null => false
    t.integer  "character_id",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",             :default => 1
    t.datetime "collected_at"
    t.integer  "workers",           :default => 0
    t.text     "worker_friend_ids",                :null => false
  end

  add_index "properties", ["character_id"], :name => "index_properties_on_character_id"

  create_table "property_types", :force => true do |t|
    t.string   "name",                  :limit => 100, :default => "",     :null => false
    t.text     "description"
    t.string   "availability",          :limit => 30,  :default => "shop", :null => false
    t.integer  "level",                                :default => 1
    t.integer  "basic_price",           :limit => 8
    t.integer  "vip_price"
    t.string   "image_file_name",                      :default => "",     :null => false
    t.string   "image_content_type",    :limit => 100, :default => "",     :null => false
    t.integer  "image_file_size"
    t.integer  "income"
    t.text     "requirements"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "upgrade_limit"
    t.integer  "upgrade_cost_increase"
    t.string   "plural_name",           :limit => 100, :default => "",     :null => false
    t.string   "state",                 :limit => 50,  :default => "",     :null => false
    t.integer  "collect_period",                       :default => 1
    t.text     "payouts"
    t.datetime "image_updated_at"
    t.integer  "income_by_level",                      :default => 0
    t.integer  "workers"
    t.string   "worker_names",                         :default => "",     :null => false
  end

  create_table "relations", :force => true do |t|
    t.integer  "owner_id",                                         :null => false
    t.integer  "character_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "inventory_effects"
    t.string   "type",              :limit => 50,  :default => "", :null => false
    t.string   "name",              :limit => 100, :default => "", :null => false
    t.integer  "level"
    t.integer  "attack"
    t.integer  "defence"
    t.integer  "health"
    t.integer  "energy"
    t.integer  "stamina"
  end

  add_index "relations", ["owner_id", "character_id"], :name => "index_relations_on_source_id_and_target_id"

  create_table "settings", :force => true do |t|
    t.string   "alias",      :limit => 100, :default => "", :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simulations", :force => true do |t|
    t.integer "admin_id"
    t.integer "user_id"
  end

  create_table "stories", :force => true do |t|
    t.string   "alias",              :limit => 70,  :default => "", :null => false
    t.string   "title",              :limit => 200, :default => "", :null => false
    t.string   "description",        :limit => 200, :default => "", :null => false
    t.string   "action_link",        :limit => 50,  :default => "", :null => false
    t.string   "payout_message",                    :default => "", :null => false
    t.string   "image_file_name",                   :default => "", :null => false
    t.string   "image_content_type", :limit => 100, :default => "", :null => false
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "payouts"
    t.string   "state",              :limit => 50,  :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "story_visits", :force => true do |t|
    t.integer  "character_id",                               :null => false
    t.integer  "story_id"
    t.string   "story_alias",  :limit => 70, :default => "", :null => false
    t.integer  "reference_id",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "publisher_id"
  end

  add_index "story_visits", ["character_id", "publisher_id", "reference_id"], :name => "index_on_character_publisher_reference"

  create_table "translations", :force => true do |t|
    t.string   "key",        :default => "", :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "facebook_id",            :limit => 8,                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_fan_specials",                     :default => true
    t.string   "reference",              :limit => 100, :default => "",      :null => false
    t.integer  "referrer_id"
    t.string   "access_token",                          :default => "",      :null => false
    t.integer  "wall_privacy_level",                    :default => 2
    t.integer  "signup_ip",              :limit => 8
    t.integer  "last_visit_ip",          :limit => 8
    t.datetime "last_visit_at"
    t.string   "first_name",             :limit => 50,  :default => "",      :null => false
    t.string   "last_name",              :limit => 50,  :default => "",      :null => false
    t.integer  "gender"
    t.integer  "timezone"
    t.string   "locale",                 :limit => 5,   :default => "en_US", :null => false
    t.datetime "access_token_expire_at"
    t.string   "third_party_id",         :limit => 50,  :default => "",      :null => false
    t.string   "email",                                 :default => "",      :null => false
    t.boolean  "banned"
    t.string   "ban_reason",             :limit => 100, :default => "",      :null => false
    t.boolean  "paying"
    t.binary   "friend_ids"
    t.boolean  "installed",                             :default => true
    t.string   "last_visit_user_agent",  :limit => 250, :default => "",      :null => false
  end

  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id"
  add_index "users", ["reference"], :name => "index_users_on_reference"

  create_table "vip_money_operations", :force => true do |t|
    t.string   "type",           :limit => 50,  :default => "", :null => false
    t.integer  "character_id",                                  :null => false
    t.integer  "amount"
    t.integer  "reference_id"
    t.string   "reference_type", :limit => 100, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vip_money_operations", ["type", "reference_type", "reference_id"], :name => "index_on_name_ref_type_ref_id"

  create_table "visibilities", :force => true do |t|
    t.integer  "target_id",                                       :null => false
    t.string   "target_type",       :limit => 50, :default => "", :null => false
    t.integer  "character_type_id",                               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "visibilities", ["target_id", "target_type"], :name => "index_visibilities_on_target_id_and_target_type"

  create_table "wall_posts", :force => true do |t|
    t.integer  "character_id",                    :null => false
    t.integer  "author_id",                       :null => false
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",      :default => false, :null => false
  end

  add_index "wall_posts", ["character_id"], :name => "index_wall_posts_on_character_id"

end
