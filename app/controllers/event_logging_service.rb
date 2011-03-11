class EventLoggingService

  def self.log_mission_event(result, completed)
    event_data = {
      :character_id => result.character.id,
      :character_level => result.character.level,
      :mission_id => resule.mission.id,
      :money => result.money,
      :experience => result.experience
    }.to_json
    log_event(completed ? "mission_completed" : "mission_fulfilled", event_data)
  end

  def self.log_engage_event(monster)
    event_data = {
      :monster_id => monster.id,
      :monster_type_id => monster.monster_type_id,
      :character_id => monster.character.id,
      :character_level => monster.character.level
    }.to_json
    log_event("monster_engaged", event_data)
  end

  def self.log_attack_event(fight, action)
    monster = fight.monster
    event_data = {
      :monster_id => monster.id,
      :monster_type_id => monster.monster_type_id,
      :character_id => monster.character.id,
      :character_level => monster.character.level,
      :monster_damage => fight.monster_damage,
      :character_damage => fight.character_damage,
      :money => fight.money,
      :experience => fight.experience
    }.to_json
    log_event("monster_" + action, event_data)
  end

  def self.log_reward_event(fight)
    monster = fight.monster
    event_data = {
      :monster_id => monster.id,
      :monster_type_id => monster.monster_type_id,
      :character_id => monster.character.id,
      :character_level => monster.character.level
    }.to_json
    log_event("reward_collected", event_data)
  end

  def self.log_upgrade_event(character, attribute_name)
    event_data = {
      :character_id => character.id,
      :character_level => character.level,
      :attribute_name => attribute_name,
      :attribute_value => character.attributes[attribute_name]
    }.to_json
    log_event("character_upgraded", event_data)
  end

  def self.log_leveup_event(character)
    event_data = {
      :character_id => character.id,
      :character_level => character.level
    }.to_json
    log_event("character_levelup", event_data)
  end

  def self.log_fight_event(fight)
    event_data = {
      :attacker_id => fight.attacker.id,
      :attacker_level => fight.attacker.level,
      :victim_id => fight.victim.id,
      :won => fight.attacker_won?,
      :is_responce => fight.is_response?,
      :attacker_damage => fight.attacker_damage,
      :victim_damage => fight.victim_damage,
      :winner_money => fight.winner_money,
      :loser_money => fight.loser_money,
      :experience => fight.experience
    }.to_json
    log_event("character_fight", event_data)
  end

  def self.log_trade_event(character, item, amount, action)
    event_data = {
      :character_id => character.id,
      :character_level => character.level,
      :item_id => item.id,
      :basic_price => item.basic_price,
      :vip_price => item.vip_price,
      :amount => amount
    }.to_json
    log_event("item_" + action, event_data)
  end

  def self.log_market_event(item, action)
    event_data = {
      :character_id => item.character.id,
      :character_level => item.character.level,
      :item_id => item.id,
      :basic_price => item.basic_price,
      :vip_price => item.vip_price,
      :amount => item.amount
    }.to_json
    log_event("market_item_" + action, event_data)
  end

  def self.log_bank_event(operation, action)
    event_data = {
      :character_id => operation.character.id,
      :character_level => operation.character.level,
      :amount => operation.amount
    }.to_json
    log_event("bank_" + action, event_data)
  end

  def self.log_equip_event(inventory, placement, action)
    event_data = {
      :character_id => inventory.character.id,
      :character_level => inventory.character.level,
      :item_id => inventory.item.id,
      :placement => placement
    }.to_json
    log_event("item_" + action, event_data)
  end



  protected
  
  def self.log_event(type, data)
    $redis.rpush(type, data)
  end
end
