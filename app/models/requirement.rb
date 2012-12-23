class Requirement
  attr_accessor :character

  def initialize(character)
    @character = character
    @attributes = Hash.new(0)
    @items = Hash.new(0)
    @properties = []

    yield self if block_given?
  end

  %w{
    basic_money vip_money
    level experience points
    attack defence health energy stamina
    attack_points defence_points health_points energy_points stamina_points
    hp ep sp
    alliance_size
  }.each do |attribute|
    define_method("#{ attribute }") do |value|
      @attributes[attribute.to_sym] = value if value > @attributes[attribute.to_sym]
    end
  end

  def item(key, amount = 1)
    @items[key.to_sym] = amount if amount > @items[key.to_sym]
  end

  def property(key)
    @properties << key.to_sym
    @properties.uniq!
  end

  def satisfied?
    unsatisfied.empty?
  end

  def unsatisfied
    [].tap do |result|
      @attributes.each do |name, value|
        result << [:attribute, name, value] if @character.send(name) < value
      end

      @items.each do |key, amount|
        if item = Item[key]
          result << [:item, item, amount] if @character.inventories.count(item) < amount
        end
      end

      # TODO: Implement property requirement check
    end
  end

  def as_json(*args)
    unsatisfied.as_json
  end
end