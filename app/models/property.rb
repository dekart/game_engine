class Property < ActiveRecord::Base
  belongs_to :character
  belongs_to :property_type

  delegate :name, :plural_name, :description, :image, :image?, :basic_price, :vip_price, :income, :to => :property_type

  attr_accessor :charge_money, :deposit_money, :basic_money, :vip_money

  validate :enough_character_money?, :enough_property_slots?

  before_save :charge_or_deposit_character
  after_destroy :deposit_character

  def sell_price
    Setting.p(:property_sell_price, property_type.inflated_price(amount)).ceil
  end

  def total_income
    self.income * self.amount
  end

  def owner
    self.character
  end

  def maximum_amount
    self.property_type.purchase_limit || Setting.i(:property_maximum_amount)
  end

  protected

  def enough_property_slots?
    if buying? and amount > maximum_amount
      errors.add(:character, :too_much_properties, :plural_name => plural_name)
    end
  end

  def enough_character_money?
    return unless charge_money and changes["amount"]

    if buying?
      errors.add(:character, :not_enough_basic_money, :name => name) if character.basic_money < total_buy_price
      errors.add(:character, :not_enough_vip_money, :name => name) if character.vip_money < vip_price * buying_amount
    end
  end

  def charge_or_deposit_character
    return unless changes["amount"]
    
    if buying? # Buying properties, should charge
      if charge_money
        self.basic_money  = total_buy_price
        self.vip_money    = vip_price * buying_amount

        character.charge(basic_money, vip_money)
      end
    else # Selling properties, should deposit
      deposit_character
    end
  end

  def deposit_character
    if deposit_money
      self.basic_money = total_sell_price

      character.basic_money += self.basic_money

      character.save
    end
  end

  def buying?
    buying_amount > 0
  end

  def buying_amount
    changes["amount"] ? changes["amount"].last - changes["amount"].first : 0
  end

  def total_buy_price
    price = 0

    (changes["amount"].first + 1).upto(changes["amount"].last) do |amount|
      price += property_type.inflated_price(amount)
    end

    price
  end

  def selling?
    selling_amount > 0
  end

  def selling_amount
    changes["amount"] ? changes["amount"].first - changes["amount"].last : 0
  end

  def total_sell_price
    if changes["amount"]
      amount_from = changes["amount"].first
      amount_to   = changes["amount"].last
    else
      amount_from = amount
      amount_to   = 0
    end

    price = 0

    amount_from.downto(amount_to + 1) do |amount|
      price += property_type.inflated_price(amount)
    end

    Setting.p(:property_sell_price, price).ceil
  end
end
