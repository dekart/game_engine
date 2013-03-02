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
    {}.tap do |result|
      @values.each do |key, value|
        case value
        when Range
          result[key] = [:range, value.begin, value.end]
        # when Array
        #   result[key] = value unless value.empty?
        when Numeric
          result[key] = value unless value == 0
        when Hash
          result[key] = value.values unless value.empty?
        end
      end
    end.as_json(*args)
  end

  def give_spendable_attribute(attribute, amount, maximum, exceed_maximum = false)
    @values[attribute] += amount
  end

  def take_spendable_attribute(attribute, amount)
    @values[attribute] -= amount
  end

  def give_basic_attribute(name, amount)
    if amount.is_a?(Numeric) and @values[name].is_a?(Numeric)
      @values[name] += amount
    elsif amount.is_a?(Numeric) and @values[name].is_a?(Range)
      @values[name] = (@values[name].begin + amount) .. (@values[name].end + amount)
    elsif amount.is_a?(Range) and @values[name].is_a?(Numeric)
      @values[name] = (@values[name] + amount.begin) .. (@values[name] + amount.end)
    else
      @values[name] = (@values[name].begin + amount.begin) .. (@values[name].end + amount.end)
    end
  end

  def take_basic_attribute(name, amount)
    give_basic_attribute(name, amount.is_a?(Range) ? (-amount.end .. -amount.begin) : -amount)
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
    give_basic_attribute(:basic_money, amount)
  end

  def take_basic_money(amount)
    take_basic_attribute(:basic_money, amount)
  end

  def give_experience(amount)
    give_basic_attribute(:experience, amount)
  end

  def give_upgrade_points(amount)
    give_basic_attribute(:points, amount)
  end

  def take_upgrade_points(amount)
    take_basic_attribute(:points, amount)
  end

  def give_vip_money(amount)
    give_basic_attribute(:vip_money, amount)
  end

  def take_vip_money(amount)
    take_basic_attribute(:vip_money, amount)
  end

  def give_mercenaries(amount)
    give_basic_attribute(:mercenaries, amount)
  end

  def take_mercenaries(amount)
    take_basic_attribute(:mercenaries, amount)
  end

  def give_item(item, amount = 1)
    @values[:items][item.key] ||= [item, 0]
    @values[:items][item.key][1] += amount
  end

  def take_item(item, amount = 1)
    @values[:items][item.key] ||= [item, 0]
    @values[:items][item.key][1] -= amount
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

  def increase_attribute(attribute, amount)
    @values[attribute] += amount
  end

  def decrease_attribute(attribute, amount)
    @values[attribute] -= amount
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