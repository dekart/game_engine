class EventLoggingService
  def self.log_event(event_type, *args)
    data = {
      :event_type => event_type,
      :occurred_at => Time.now
    }.merge self.new.send("#{event_type}_event_data", *args)

    $redis.lpush(:logged_events, data.to_json)
  end

  def self.get_next_batch(size)
    $redis.lrange(:logged_events, 0, size - 1)
  end

  def self.trim_event_list(size)
    $redis.ltrim(:logged_events, size, -1)
  end

  def self.empty_event_list?
    $redis.llen(:logged_events) == 0
  end

  def assignment_created_event_data(assignment)
    character = assignment.relation.owner
    character.event_data.merge assignment.event_data
  end

  alias assignment_destroyed_event_data assignment_created_event_data

  def bank_deposit_event_data(operation)
    operation.character.event_data.merge operation.event_data
  end

  alias bank_withdraw_event_data bank_deposit_event_data

  def character_levelup_event_data(character)
    character.event_data
  end

  def character_upgraded_event_data(character, attribute_name)
    {
      :reference_type => attribute_name,
      :int_value => character.attributes[attribute_name]
    }.merge character.event_data
  end

  def character_fight_event_data(fight)
    fight.attacker.event_data.merge fight.event_data
  end

  def item_bought_event_data(character, item, amount)
    {
      :reference_id => item.id,
      :reference_type => "Item",
      :amount => amount
    }.merge character.event_data
  end

  alias item_sold_event_data item_bought_event_data

  def item_equipped_event_data(inventory, placement)
    {
      :reference_id => inventory.item.id,
      :reference_type => "Item",
      :string_value => placement
    }.merge inventory.character.event_data
  end

  alias item_unequipped_event_data item_equipped_event_data

  def all_equipped_event_data(character)
    character.event_data
  end

  alias all_unequipped_event_data all_equipped_event_data

  def item_given_event_data(character, receiver, item)
    {
      :reference_id => receiver.id,
      :reference_type => "Character",
      :reference_level => receiver.level,
      :int_value => item.id
    }.merge character.event_data
  end

  def collection_applied_event_data(character, collection)
    character.event_data.merge collection.event_data
  end

  def market_item_created_event_data(market_item)
    market_item.character.event_data.merge market_item.event_data
  end

  alias market_item_bought_event_data market_item_created_event_data
  alias market_item_destroyed_event_data market_item_created_event_data

  def mission_fulfilled_event_data(result)
    result.character.event_data.merge result.event_data
  end

  alias mission_completed_event_data mission_fulfilled_event_data

  def monster_engaged_event_data(monster)
    monster.character.event_data.merge monster.event_data
  end

  def monster_attacked_event_data(monster_fight)
    character = monster_fight.monster.character
    character.event_data.merge monster_fight.event_data
  end

  alias monster_killed_event_data monster_attacked_event_data

  def reward_collected_event_data(fight)
    monster = fight.monster
    monster.character.event_data.merge monster.event_data
  end

  def property_bought_event_data(property)
    property.character.event_data.merge property.event_data
  end

  alias property_upgraded_event_data property_bought_event_data
  alias property_income_collected_event_data property_bought_event_data
end
