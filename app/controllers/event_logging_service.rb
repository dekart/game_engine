class EventLoggingService
  def self.log_event(event_type, *args)
    data = {
      :event_type => event_type,
      :occurred_at => Time.now
    }.merge self.new.send("#{event_type}_event_data", *args)

    $redis.rpush(:logged_events, data.to_json)
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

  def character_attacked_event_data(fight)
    fight.attacker.event_data.
      merge(fight.attacker_event_data).
      merge({:export => true})
  end
  
  def character_under_attack_event_data(fight)
    fight.victim.event_data.
      merge(fight.victim_event_data).
      merge({:export => true})
  end

  def item_bought_event_data(character, item, amount)
    {
      :reference_id => item.id,
      :reference_type => "Item",
      :string_value => item.name,
      :amount => amount,
      :basic_money => -item.basic_price * amount,
      :vip_money => -item.vip_price * amount,
      :export => true,
    }.merge character.event_data
  end

  def item_sold_event_data(character, inventory, amount)
    {
      :reference_id => inventory.item.id,
      :reference_type => "Item",
      :string_value => inventory.item.name,
      :amount => amount,
      :basic_money => inventory.sell_price * amount,
      :vip_money => 0,
      :export => true,
    }.merge character.event_data
  end

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

  def collection_applied_event_data(character, result)
    character.event_data.
      merge(result.collection.event_data).
      merge(payouts_event_data(result.payouts)).
      merge({:export => true})
  end

  def market_item_created_event_data(market_item)
    market_item.character.event_data.merge market_item.event_data(false)
  end
    
  alias market_item_destroyed_event_data market_item_created_event_data

  def market_item_bought_event_data(market_item, buyer)
    buyer.event_data.
      merge(market_item.event_data(true)).
      merge({:export => true})
  end

  def market_item_sold_event_data(market_item)
    market_item.character.event_data.
      merge(market_item.event_data(false)).
      merge({:export => true})
  end

  def mission_fulfilled_event_data(result)
    result.character.event_data.
      merge(result.event_data).
      merge(payouts_event_data(result.payouts)).
      merge({:export => true})
  end

  alias mission_completed_event_data mission_fulfilled_event_data

  def monster_engaged_event_data(monster)
    monster.character.event_data.merge monster.event_data
  end

  def monster_attacked_event_data(monster_fight)
    character = monster_fight.monster.character
    character.event_data.
      merge(monster_fight.event_data).
      merge({:export => true})
  end

  alias monster_killed_event_data monster_attacked_event_data

  def reward_collected_event_data(fight)
    monster = fight.monster
    monster.character.event_data.
      merge(monster.event_data).
      merge(payouts_event_data(fight.payouts)).
      merge({:export => true})
  end

  def property_bought_event_data(property)
    property.character.event_data.
      merge(property.event_data).
      merge({:export => true})
  end

  def property_upgraded_event_data(property)
    property.character.event_data.
      merge(property.event_data).
      merge({:basic_money => -property.property_type.upgrade_price(property.level - 1), :export => true})
  end
  
  def property_income_collected_event_data(property, payouts)
    property.character.event_data.
      merge(property.event_data).
      merge(payouts_event_data(payouts)).
      merge({:export => true})
  end

  def properties_income_collected_event_data(properties, payouts)
    properties.first.character.event_data.
      merge(:reference_id => properties.collect(&:id).join(','), :reference_type => "Property").
      merge(payouts_event_data(payouts)).
      merge({:export => true})
  end
  
  def payouts_event_data(payouts)
    if !payouts.nil?   
      data = {:basic_money => 0, :vip_money => 0, :health => 0, :energy => 0, :stamina => 0, :experience => 0}
      payouts.items.each do |item|
        case
        when item.instance_of?(Payouts::BasicMoney)
          data[:basic_money] += (item.action == :add ? item.valuecation : -item.value)
        when item.instance_of?(Payouts::VipMoney)
          data[:vip_money] += (item.action == :add ? item.value : -item.value)
        when item.instance_of?(Payouts::HealthPoint)
          data[:health] += (item.action == :add ? item.value : -item.value)
        when item.instance_of?(Payouts::EnergyPoint)
          data[:energy] += (item.action == :add ? item.value : -item.value)
        when item.instance_of?(Payouts::StaminaPoint)
          data[:stamina] += (item.action == :add ? item.value : -item.value)
        when item.instance_of?(Payouts::Experience)
          data[:experience] += (item.action == :add ? item.value : -item.value)
        when item.instance_of?(Payouts::Item)
          data[:string_value] = item.item.name if item.action == :add
        end
      end
      
      data.reject{|d,v| v == 0}
    else
      {}
    end
  end
end
