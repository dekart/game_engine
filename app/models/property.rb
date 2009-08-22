class Property < ActiveRecord::Base
  MAXIMUM_AMOUNT = 2000

  belongs_to :character
  belongs_to :property_type

  delegate :name, :description, :image, :basic_price, :vip_price, :money_min, :money_max, :to => :property_type

  attr_accessor :free_of_charge

  validate_on_create :enough_character_money?, :enough_property_slots?

  after_create  :charge_character

  def sell_price
    (self.basic_price * 0.5).ceil
  end

  def sell
    self.transaction do
      self.character.basic_money += self.sell_price
      self.save

      self.destroy
    end
  end

  def income
    self.money_min
  end

  def owner
    self.character
  end

  protected

  def enough_property_slots?
    self.errors.add(:character, :too_much_properties) if character.properties.size >= MAXIMUM_AMOUNT
  end

  def enough_character_money?
    return if self.free_of_charge

    self.errors.add(:character, :not_enough_money) unless self.character.can_buy?(self)
  end

  def charge_character
    return if self.free_of_charge

    self.transaction do
      self.character.basic_money  -= self.basic_price if self.basic_price.to_i > 0
      self.character.vip_money    -= self.vip_price if self.vip_price.to_i > 0

      self.character.save!
    end
  end
end
