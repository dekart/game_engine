puts "Seeding settings..."

Setting[:assignment_mercenaries]                ||= true
Setting[:assignment_attack_bonus]               ||= 20
Setting[:assignment_defence_bonus]              ||= 20
Setting[:assignment_fight_damage_multiplier]    ||= 3.5
Setting[:assignment_fight_damage_divider]       ||= 2.0
Setting[:assignment_fight_income_multiplier]    ||= 2.0
Setting[:assignment_fight_income_divider]       ||= 1.0
Setting[:assignment_mission_energy_multiplier]  ||= 1.0
Setting[:assignment_mission_energy_divider]     ||= 4.0
Setting[:assignment_mission_income_multiplier]  ||= 4.0
Setting[:assignment_mission_income_divider]     ||= 2.0

Setting[:bank_deposit_fee] ||= 10

Setting[:character_attack_upgrade] ||= 1
Setting[:character_defence_upgrade] ||= 1
Setting[:character_health_upgrade] ||= 5
Setting[:character_energy_upgrade] ||= 1
Setting[:character_points_per_upgrade] ||= 5
Setting[:character_vip_money_per_upgrade] ||= 0
Setting[:character_vip_money_per_upgrade_per_level] ||= 0
Setting[:character_stamina_upgrade] ||= 1
Setting[:character_stamina_upgrade_points] ||= 2
Setting[:character_attack_upgrade_points] ||= 1
Setting[:character_defence_upgrade_points] ||= 1
Setting[:character_health_upgrade_points] ||= 1
Setting[:character_energy_upgrade_points] ||= 1

Setting[:character_health_restore_period] ||= 60
Setting[:character_energy_restore_period] ||= 120
Setting[:character_stamina_restore_period] ||= 180
Setting[:character_income_calculation_period] ||= 60
Setting[:character_weakness_minimum] ||= 5
Setting[:character_weakness_minimum_formula] ||= 'absolute'

Setting[:clan_create_for_vip_money] ||= 25
Setting[:clan_change_image_vip_money] ||= 10
Setting[:clan_repeat_invite_delay] ||= 7 # days
Setting[:clan_max_size] ||= 50

Setting[:dashboard_news_count] ||= 30

Setting[:premium_money_price] ||= 5
Setting[:premium_money_amount] ||= 1000
Setting[:premium_energy_price] ||= 5
Setting[:premium_health_price] ||= 1
Setting[:premium_points_price] ||= 5
Setting[:premium_points_amount] ||= 5
Setting[:premium_mercenary_price] ||= 10
Setting[:premium_change_name_price] ||= 10
Setting[:premium_reset_attributes_price] ||= 10
Setting[:premium_stamina_price] ||= 5
Setting[:premium_credits_enabled] ||= true
Setting[:premium_offer_wall_enabled] ||= false

Setting[:fight_victim_show_limit] ||= 10
Setting[:fight_attack_repeat_delay] ||= 60
Setting[:fight_stamina_required] ||= 1
Setting[:fight_experience] ||= 50
Setting[:fight_money_loot] ||= 10
Setting[:fight_max_loser_damage] ||= 50
Setting[:fight_max_winner_damage] ||= 90
Setting[:fight_alliance_attack] ||= true
Setting[:fight_max_money] ||= 10000
Setting[:fight_min_money] ||= 10
Setting[:fight_min_money_per_level] ||= 1.5
Setting[:fight_max_difference] ||= 30
Setting[:fight_weak_opponents] ||= true
Setting[:fight_victim_hp_decrease_if_character_was_online] ||= 1
Setting[:fight_optout_minimum_timeframe] ||= 7

Setting[:rating_show_limit] ||= 20

Setting[:inventory_sell_price] ||= 50
Setting[:inventory_exchange_enabled] ||= true

Setting[:item_show_special] ||= 3
Setting[:promo_block_minimum_level] ||= 3

Setting[:property_sell_price] ||= 50
Setting[:property_upgrade_limit] ||= 2000
Setting[:property_first_collect_time] ||= 5.minutes.to_i
Setting[:property_worker_price] ||= 2
Setting[:property_worker_hire_delay] ||= 24

Setting[:user_admins] ||= "682180971, 573513043"

Setting[:invitation_direct_link] ||= false

Setting[:relation_show_limit]         ||= 10
Setting[:relation_max_alliance_size]  ||= 500
Setting[:relation_friends_only]       ||= false
Setting[:relation_for_invitation_limit] ||= 4
Setting[:relation_repeat_invite_delay] ||= 7 # days

Setting[:mission_group_show_limit] ||= 4
Setting[:mission_completion_dialog] ||= true
Setting[:mission_help_money] ||= 25
Setting[:mission_help_experience] ||= 25
Setting[:mission_help_enabled] ||= true

Setting[:app_google_analytics_id] ||= ""
Setting[:app_fan_page_url] ||= ""
Setting[:app_standalone_enabled] ||= false

Setting[:gifting_enabled] ||= true
Setting[:gifting_item_show_limit] ||= 10
Setting[:gifting_repeat_accept_delay] ||= 24

Setting[:wall_enabled] ||= true
Setting[:wall_posts_show_limit] ||= 10

Setting[:character_default_name] ||= ""
Setting[:character_equipment_slots] ||= 5
Setting[:character_auto_equipment] ||= false
Setting[:character_relations_per_equipment_slot] ||= 3

Setting[:hit_list_enabled] ||= true
Setting[:hit_list_minimum_reward] ||= 10_000
Setting[:hit_list_reward_fee] ||= 20
Setting[:hit_list_display_limit] ||= 20
Setting[:hit_list_repeat_listing_delay] ||= 12

Setting[:hospital_enabled] ||= true
Setting[:hospital_price] ||= 10
Setting[:hospital_price_per_point_per_level] ||= 2.5
Setting[:hospital_delay] ||= 5
Setting[:hospital_delay_per_level] ||= 1

Setting[:market_enabled]          ||= true
Setting[:market_basic_price_fee]  ||= 10
Setting[:market_vip_price_fee]    ||= 10
Setting[:market_expire_period]    ||= 24

Setting[:collections_enabled] ||= true
Setting[:collections_request_time] ||= 48

Setting[:boosts_enabled] ||= false

Setting[:monsters_enabled] ||= true
Setting[:monsters_reward_time] ||= 24
Setting[:monster_minimum_damage] ||= 10
Setting[:monsters_maximum_reward_collectors] ||= 5

Setting[:monster_fight_power_attack_factor] ||= 5

Setting[:notifications_friends_to_invite_show_requests_count] ||= 40
Setting[:notifications_send_gift_show_requests_count] ||= 100

Setting[:chat_max_messages] ||= 50
Setting[:chat_update_time] ||= 10.seconds.to_i
Setting[:chat_online_users_expiration_time] ||= 1.minute.to_i
Setting[:chat_max_length] ||= 500
Setting[:chat_enabled] ||= true
Setting[:global_chat_enabled] ||= true

Setting[:contests_show_after_finished_time] ||= 5
Setting[:contests_leaders_show_limit] ||= 100

Setting[:personal_discount_enabled] ||= false
Setting[:personal_discount_minimum_price] ||= 10
Setting[:personal_discount_minimum_discount] ||= 5
Setting[:personal_discount_maximum_discount] ||= 25
Setting[:personal_discount_time_frame] ||= 60
Setting[:personal_discount_period] ||= 24

Setting[:friends_invite_enabled] ||= true
Setting[:stream_dialog_enabled] ||= true
Setting[:invitation_dialog_custom] ||= true

Setting[:achievements_enabled] ||= true

Setting[:app_toolbar] ||= ''
Setting[:app_toolbar_applifier_id] ||= ''
Setting[:app_toolbar_appatyze_id] ||= ''
Setting[:app_toolbar_minimum_level] ||= 1

# total score
Setting[:total_score_fights_won_factor] ||= 1
Setting[:total_score_killed_monsters_count_factor] ||= 1
Setting[:total_score_total_monsters_damage_factor] ||= 1
Setting[:total_score_total_money_factor] ||= 1
Setting[:total_score_missions_succeeded_factor] ||= 1
Setting[:total_score_level_factor] ||= 1

Setting[:total_score_publishing_in_facebook_enabled] ||= true
Setting[:browser_check_enabled] ||= true
# Put your custom settings below this line