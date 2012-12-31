class Reward < RewardPreview
  attr_accessor :character, :values

  delegate :[], :[]=, :to => :values

  def initialize(character, reference = nil)
    @reference = reference

    super(character)
  end


  def give_spendable_attribute(attribute, amount, maximum, exceed_maximum = false)
    new_value = @character.send(attribute) + amount

    @character.send("#{ attribute }=", new_value)

    if new_value > maximum and exceed_maximum
      @character.send("#{ attribute }_updated_at=", nil)
    end

    super(attribute, amount, maximum, exceed_maximum)
  end

  def take_spendable_attribute(attribute, amount)
    @character.send("#{ attribute }=", @character.send(attribute) - amount)

    super(attribute, amount)
  end

  def give_basic_money(amount)
    amount = amount_to_number(amount)

    @character.charge(- amount, 0, @reference)

    super(amount)
  end

  def take_basic_money(amount)
    amount = amount_to_number(amount)

    @character.charge(amount, 0, @reference)

    super(amount)
  end

  def give_experience(amount)
    amount = amount_to_number(amount)

    @character.experience += amount

    super(amount)
  end

  def give_upgrade_points(amount)
    amount = amount_to_number(amount)

    @character.points += amount

    super(amount)
  end

  def take_upgrade_points(amount)
    amount = amount_to_number(amount)

    @character.points -= amount
    @character.points = 0 if @character.points < 0

    super(amount)
  end

  def give_vip_money(amount)
    amount = amount_to_number(amount)

    @character.charge(0, - amount, @reference)

    super(amount)
  end

  def take_vip_money(amount)
    amount = amount_to_number(amount)

    @character.charge(0, amount, @reference)

    super(amount)
  end

  def give_mercenaries(amount)
    amount = amount_to_number(amount)

    amount.times do
      character.mercenary_relations.build
    end

    super(amount)
  end

  def take_mercenaries(amount)
    amount = amount_to_number(amount)

    character.mercenary_relations[0 ... amount].each do |mercenary|
      mercenary.destroy

      super(1)
    end
  end

  def give_item(item, amount = 1)
    if item = find_item(item)
      @character.inventories.give!(item, amount)

      super(item, amount)
    end
  end

  def take_item(item, amount = 1)
    if item = find_item(item)
      @character.inventories.take!(item, amount)

      super(item, amount)
    end
  end

  def give_random_item(item_set, shift_set = false)
    give_item(GameData::ItemSet.sets[item_set].random(shift_set ? r.character.id : 0))
  end

  def take_random_item(item_set, shift_set = false)
    take_item(give_item(GameData::ItemSet.sets[item_set].random(shift_set ? r.character.id : 0)))
  end

  def give_property(property_type)
    @character.properties.give!(property_type)

    super(property_type)
  end

  def increase_attribute(attribute, amount)
    @character.send("#{ attribute }=", @character.send(attribute) + amount)

    super(amount)
  end

  def decrease_attribute(attribute, amount)
    @character.send("#{ attribute }=", @character.send(attribute) - amount)

    super(amount)
  end

  protected

  def amount_to_number(amount)
    case amount
    when Numeric
      amount
    when Range
      amount.begin + rand(amount.end - amount.begin)
    end
  end
end