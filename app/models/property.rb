class Property < ActiveRecord::Base
  belongs_to :character
  belongs_to :property_type

  delegate :name, :description, :image, :image?, :basic_price, :vip_price, :income, :to => :property_type

  attr_accessor :charge_money, :deposit_money, :money_return

  validate :enough_character_money?, :enough_property_slots?

  before_save :charge_or_deposit_character
  after_destroy :deposit_character

  def sell_price
    (self.basic_price * Configuration[:property_sell_price] * 0.01).ceil
  end

  def total_income
    self.income * self.amount
  end

  def owner
    self.character
  end

  def maximum_amount
    self.property_type.purchase_limit || Configuration[:property_maximum_amount]
  end

  protected

  def enough_property_slots?
    if buying? and amount > maximum_amount
      errors.add(:character, :too_much_properties)
    end
  end

  def enough_character_money?
    return unless charge_money and changes["amount"]

    if buying?
      errors.add(:character, :not_enough_basic_money) if character.basic_money < basic_price * buying_amount
      errors.add(:character, :not_enough_vip_money) if character.vip_money < vip_price * buying_amount
    end
  end

  def charge_or_deposit_character
    return unless changes["amount"]
    
    if buying? # Buying properties, should charge
      if charge_money
        character.charge(basic_price * buying_amount, vip_price * buying_amount)
      end
    else # Selling properties, should deposit
      if deposit_money
        self.money_return = sell_price * selling_amount

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

  def buying?
    buying_amount > 0
  end

  def buying_amount
    changes["amount"] ? changes["amount"].last - changes["amount"].first : 0
  end

  def selling?
    selling_amount > 0
  end

  def selling_amount
    changes["amount"] ? changes["amount"].first - changes["amount"].last : 0
  end
end
