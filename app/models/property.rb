class Property < ActiveRecord::Base
  belongs_to :character
  belongs_to :property_type

  delegate :name, :plural_name, :description, :image, :image?, :basic_price, :vip_price, :income, :to => :property_type

  attr_accessor :charge_money

  validate :can_be_upgraded?, :enough_character_money?

  def total_income
    income * level
  end

  def owner
    character
  end

  def maximum_level
    property_type.upgrade_limit || Setting.i(:property_upgrade_limit)
  end

  def buy
    @validate_money = true

    if valid?
      transaction do
        save! && character.charge(basic_price, vip_price)
      end

      true
    else
      false
    end
  end

  def upgrade
    return false if new_record?

    @validate_money = true
    
    if valid?
      transaction do
        increment(:level)

        save! && character.charge(property_type.upgrade_price(level), vip_price)
      end
    else
      false
    end
  end

  protected

  def can_be_upgraded?
    if level > maximum_level
      errors.add(:character, :too_much_properties, :plural_name => plural_name)
    end
  end

  def enough_character_money?
    if @validate_money
      errors.add(:character, :not_enough_basic_money, :name => name) if character.basic_money < basic_price
      errors.add(:character, :not_enough_vip_money, :name => name) if character.vip_money < vip_price
    end
  end
end
