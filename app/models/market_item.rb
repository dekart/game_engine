class MarketItem < ActiveRecord::Base
  belongs_to :character
  belongs_to :inventory, :counter_cache => true

  delegate(*(%w{name plural_name description image image? effects effects? payouts} + [{:to => :inventory}]))

  attr_accessible :amount, :basic_price, :vip_price

  validates_presence_of :inventory_id
  validates_presence_of :amount
  validates_numericality_of :amount, :allow_nil => true, :greater_than => -1
  validates_numericality_of :basic_price, :vip_price, :allow_nil => true, :greater_than => -1

  validate_on_create :check_amount

  before_create :destroy_previous_items, :assign_character

  %w{basic_price vip_price}.each do |attr|
    define_method(attr) do
      self[attr].to_i
    end
  end

  def price?
    basic_price > 0 or vip_price > 0
  end

  def buy!(target_character)
    if target_character.basic_money < basic_price
      errors.add(:base, :not_enough_basic_money, :name => plural_name)
    elsif target_character.vip_money < vip_price
      errors.add(:base, :not_enough_vip_money, :name => plural_name)
    else
      transaction do
        target_character.charge!(basic_price, vip_price)
        target_character.inventories.give!(inventory.item, amount)

        basic_money = basic_price - Setting.p(:market_basic_price_fee, basic_price).floor
        vip_money   = vip_price - Setting.p(:market_vip_price_fee, vip_price).floor

        character.charge!(- basic_money, - vip_money)
        character.inventories.take!(inventory.item, amount)

        destroy

        character.notifications.schedule(:market_item_sold,
          :item_id      => inventory.item_id,
          :basic_money  => basic_money,
          :vip_money    => vip_money
        )
      end
    end
  end

  protected

  def check_amount
    if amount.to_i > inventory.amount
      errors.add(:amount, :less_than_or_equal_to, :count => inventory.amount)
    end
  end

  def destroy_previous_items
    self.class.destroy_all(:inventory_id => inventory.id)
  end

  def assign_character
    self.character = inventory.character
  end
end
