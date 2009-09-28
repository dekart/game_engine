class Property < ActiveRecord::Base
  MAXIMUM_AMOUNT = 2000

  belongs_to :character
  belongs_to :property_type

  delegate :name, :description, :image, :image?, :basic_price, :vip_price, :income, :to => :property_type

  attr_accessor :charge_money, :deposit_money, :money_return

  validate :enough_character_money?, :enough_property_slots?

  before_save :charge_or_deposit_character
  after_destroy :deposit_character

  def sell_price
    (self.basic_price * 0.5).ceil
  end

  def total_income
    self.income * self.amount
  end

  def owner
    self.character
  end

  protected

  def enough_property_slots?
    errors.add(:character, :too_much_properties) if character.properties.size >= MAXIMUM_AMOUNT
  end

  def enough_character_money?
    return unless charge_money and changes["amount"]

    difference = changes["amount"].last - changes["amount"].first

    if difference > 0
      errors.add(:character, :not_enough_basic_money) if character.basic_money < basic_price * difference
      errors.add(:character, :not_enough_vip_money) if character.vip_money < vip_price * difference
    end
  end

  def charge_or_deposit_character
    return unless changes["amount"]
    
    difference = changes["amount"].first - changes["amount"].last

    if difference < 0 # Buying properties, should charge
      if charge_money
        character.charge(basic_price * difference.abs, vip_price * difference.abs)
      end
    else # Selling properties, should deposit
      if deposit_money
        self.money_return = sell_price * difference

        character.basic_money += self.money_return
        character.save
      end
    end
  end

  def deposit_character
    if deposit_money
      self.money_return = sell_price * amount

      character.basic_money += self.money_return
      character.save
    end
  end
end
