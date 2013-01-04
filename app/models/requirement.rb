class Requirement
  attr_accessor :character

  class << self
    def requirement_definition(attribute)
      define_method("#{ attribute }=") do |value|
        @attributes[attribute.to_sym] = value if value > @attributes[attribute.to_sym]
      end
    end

    def requirement_accessor(attribute)
      define_method("#{attribute}") do
        @attributes[attribute.to_sym]
      end
    end

    def requirement_check(attribute, character_field = nil)
      define_method("#{attribute}_satisfied?") do
        @character.send(character_field || attribute) >= @attributes[attribute.to_sym]
      end
    end
  end

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
    hp ep sp
    alliance_size
  }.each do |attribute|
    requirement_definition(attribute)
    requirement_accessor(attribute)
    requirement_check(attribute)
  end

  %w{attack defence health energy stamina}.each do |attribute|
    requirement_definition(attribute)
    requirement_accessor(attribute)
    requirement_check(attribute, "#{attribute}_points")
  end

  def item(key, amount = 1)
    @items[key.to_sym] = amount if amount > @items[key.to_sym]
  end

  def property(key)
    @properties << key.to_sym
    @properties.uniq!
  end

  def satisfied?
    @attributes.each do |name, value|
      return false unless send("#{ name }_satisfied?")
    end

    @items.each do |key, amount|
      return false if @character.inventories.count(GameData::Item[key]) < amount
    end

    # TODO: Implement property requirement check
    true
  end

  def as_json(*args)
    [].tap do |result|
      @attributes.each do |name, value|
        result << [:attribute, name, value, send("#{name}_satisfied?")]
      end

      @items.each do |key, amount|
        result << [:item, GameData::Item[key], amount, @character.inventories.count(item) >= amount]
      end
    end.as_json
  end
end
