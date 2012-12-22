class RewardPreview
  attr_accessor :values

  delegate :[], :[]=, :to => :values

  def initialize(character)
    @character = character

    @values = Hash.new(0)
    @values[:items] = {}
    @values[:properties] = {}

    yield self if block_given?
  end

  def as_json(*args)
    @values.reject{|k, v| v.is_a?(Enumerable) && v.empty? or v == 0 }.as_json(*args)
  end

  def give_spendable_attribute(attribute, amount, maximum, exceed_maximum = false)
    @values[attribute] += amount
  end

  def take_spendable_attribute(attribute, amount)
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
    @values[:basic_money] += amount
  end

  def take_basic_money(amount)
    @values[:basic_money] -= amount
  end

  def give_experience(amount)
    @values[:experience] += amount
  end

  def give_item(item, amount = 1)
    @values[:items][item.alias] ||= [item, 0]
    @values[:items][item.alias][1] += amount
  end

  def take_item(item, amount = 1)
    @values[:items][item.alias] ||= [item, 0]
    @values[:items][item.alias][1] -= amount
  end

  def give_random_item(item_set, shift_set = false)
    @values[:items]["random_#{ item_set }"] ||= [item_set, 0]
    @values[:items]["random_#{ item_set }"][1] += amount
  end

  def take_random_item(item_set, shift_set = false)
    @values[:items]["random_#{ item_set }"] ||= [item_set, 0]
    @values[:items]["random_#{ item_set }"][1] -= amount
  end

  def give_property(property_type)
    @values[:properties][property_type.id] ||= [property_type, 1]
  end

  def give_upgrade_points(amount)
    @values[:points] += amount
  end

  def take_upgrade_points(amount)
    @values[:points] -= amount
  end

  def give_vip_money(amount)
    @values[:vip_money] += amount
  end

  def take_vip_money(amount)
    @values[:vip_money] -= amount
  end

  def increase_attribute(attribute, amount)
    @values[attribute] += amount
  end

  def decrease_attribute(attribute, amount)
    @values[attribute] -= amount
  end

  def give_mercenaries(amount)
    @values[:mercenaries] += amount
  end

  def take_mercenaries(amount)
    @values[:mercenaries] -= amount
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