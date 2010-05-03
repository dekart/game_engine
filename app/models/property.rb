class Property < ActiveRecord::Base
  belongs_to :character
  belongs_to :property_type

  delegate :name, :plural_name, :description, :image, :image?, :basic_price, :vip_price, :income, :collect_period, :to => :property_type

  attr_accessor :charge_money

  validate :can_be_upgraded?, :enough_character_money?

  after_create :assign_collected_at

  def total_income
    income * level
  end

  def owner
    character
  end

  def maximum_level
    property_type.upgrade_limit || Setting.i(:property_upgrade_limit)
  end

  def upgrade_price
    property_type.upgrade_price(level)
  end

  def collectable?
    collected_at < Time.now - collect_period.hours
  end

  def buy!
    @validate_money = true

    if valid?
      transaction do
        save! && character.charge(basic_price, vip_price)
      end
    else
      false
    end
  end

  def upgrade!
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

  def collect_money!
    if collectable?
      returning income = total_income do
        transaction do
          update_attribute(:collected_at, Time.now)

          character.basic_money += income
          character.save
        end
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
      if character.basic_money < basic_price
        errors.add(:character, new_record? ? :not_enough_basic_money : :not_enough_basic_money_for_upgrade,
          :name         => name,
          :basic_money  => Character.human_attribute_name("basic_money")
        )
      end

      if character.vip_money < vip_price
        errors.add(:character, new_record? ? :not_enough_vip_money : :not_enough_vip_money_for_upgrade, 
          :name       => name,
          :vip_money  => Character.human_attribute_name("vip_money")
        )
      end
    end
  end

  def assign_collected_at
    update_attribute(:collected_at, created_at)
  end
end
