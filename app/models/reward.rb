class Reward
  attr_accessor :character, :values

  delegate :[], :[]=, :to => :values

  def initialize(character, reference = nil)
    @character = character
    @reference = reference

    @values = Hash.new(0)
    @values[:items] = {}
    @values[:properties] = {}

    yield self if block_given?
  end

  def as_json(*args)
    @values.reject{|k, v| v.is_a?(Enumerable) && v.empty? or v == 0 }.as_json(*args)
  end

  def give_spendable_attribute(attribute, amount, maximum, exceed_maximum = false)
    new_value = @character.send(attribute) + amount

    @character.send("#{ attribute }=", new_value)

    if new_value > maximum and exceed_maximum
      @character.send("#{ attribute }_updated_at=", nil)
    end

    @values[attribute] += amount
  end

  def take_spendable_attribute(attribute, amount)
    @character.send("#{ attribute }=", @character.send(attribute) - amount)

    @values[attribute] -= amount
  end

  def give_energy(amount, exceed_maximum = false)
    give_spendable_attribute(:ep, amount, @character.energy_points, exceed_maximum)
  end

  def take_energy(amount)
    take_spendable_attribute(:ep, amount)
  end

  def give_health(amount, exceed_maximum = false)
    give_spendable_attribute(:hp, amount, @character.health_points, exceed_maximum)
  end

  def take_health(amount)
    take_spendable_attribute(:hp, amount)
  end

  def give_stamina(amount, exceed_maximum = false)
    give_spendable_attribute(:sp, amount, @character.stamina_points, exceed_maximum)
  end

  def take_stamina(amount)
    take_spendable_attribute(:sp, amount)
  end

  def give_basic_money(amount)
    @character.charge(- amount, 0, @reference)

    @values[:basic_money] += amount
  end

  def take_basic_money(amount)
    @character.charge(amount, 0, @reference)

    @values[:basic_money] -= amount
  end

  def give_experience(amount)
    @character.experience += amount

    @values[:experience] += amount
  end

  def give_item(item, amount = 1)
    if item = find_item(item)
      @character.inventories.give!(item, amount)

      @values[:items][item.alias] ||= [item.as_json_for_reward, 0]
      @values[:items][item.alias][1] += amount
    end
  end

  def take_item(item, amount = 1)
    if item = find_item(item)
      @character.inventories.take!(item, amount)

      @values[:items][item.alias] ||= [item.as_json_for_reward, 0]
      @values[:items][item.alias][1] -= amount
    end
  end

  def give_property(property_type)
    @character.properties.give!(property_type)

    @values[:properties][property_type.id] ||= [property_type.as_json_for_reward, 1]
  end

  def give_upgrade_points(amount)
    @character.points += amount

    @values[:points] += amount
  end

  def take_upgrade_points(amount)
    @character.points -= amount
    @character.points = 0 if @character.points < 0

    @values[:points] -= amount
  end

  def give_vip_money(amount)
    @character.charge(0, - amount, @reference)

    @values[:vip_money] += amount
  end

  def take_vip_money(amount)
    @character.charge(0, amount, @reference)

    @values[:vip_money] -= amount
  end

  def increase_attribute(attribute, amount)
    @character.send("#{ attribute }=", @character.send(attribute) + amount)

    @values[attribute] += amount
  end

  def decrease_attribute(attribute, amount)
    @character.send("#{ attribute }=", @character.send(attribute) - amount)

    @values[attribute] -= amount
  end

  def give_mercenaries(amount)
    amount.times do
      character.mercenary_relations.build

      @values[:mercenaries] += 1
    end
  end

  def take_mercenaries(amount)
    character.mercenary_relations[0 ... limit].each do |mercenary|
      mercenary.destroy

      @values[:mercenaries] -= 1
    end
  end

  protected

  def find_item(item)
    if item.is_a?(::Item)
      item
    elsif item.is_a?(Symbol)
      Item[item]
    else
      ::Item.find_by_id(item)
    end
  end
end