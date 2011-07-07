class MarketItem < ActiveRecord::Base
  extend HasRequirements
  
  belongs_to :character
  belongs_to :inventory, :counter_cache => true

  named_scope :expired, Proc.new{
    {
      :conditions => ["created_at < ?", Setting.i(:market_expire_period).hours.ago]
    }
  }

  delegate(*(%w{name plural_name description image image? effects effects? boost? payouts placements} + [{:to => :inventory}]))

  attr_accessible :amount, :basic_price, :vip_price

  validates_presence_of :inventory_id
  validates_presence_of :amount
  validates_numericality_of :amount, :allow_nil => true, :greater_than => 0
  validates_numericality_of :basic_price, :vip_price, :allow_nil => true, :greater_than => -1
  
  validate_on_create :vip_price_dont_more_than_max
  validate_on_create :check_amount
  validate_on_create :item_allowed_to_sell

  before_create :destroy_previous_items, :assign_character

  %w{basic_price vip_price}.each do |attribute|
    class_eval %{
      def #{attribute}
        self[:#{attribute}] || 0
      end
    }
  end

  def price?
    basic_price > 0 or vip_price > 0
  end

  def basic_fee
    if basic_price > 0
      result = Setting.p(:market_basic_price_fee, basic_price).round
      result = 1 if result == 0
      result
    else
      0
    end
  end

  def vip_fee
    if vip_price > 0
      result = Setting.p(:market_vip_price_fee, vip_price).round
      result = 1 if result == 0
      result
    else
      0
    end
  end

  def buy!(target_character)
    if target_character.basic_money < basic_price
      errors.add(:base, :not_enough_basic_money, :name => plural_name)
    elsif target_character.vip_money < vip_price
      errors.add(:base, :not_enough_vip_money, :name => plural_name)
    else
      transaction do
        target_character.charge!(basic_price, vip_price, :market)
        target_character.inventories.give!(inventory.item, amount)

        basic_money = basic_price - basic_fee
        vip_money   = vip_price - vip_fee

        character.charge!(- basic_money, - vip_money, :market)
        character.inventories.take!(inventory, amount)

        destroy unless inventory.market_item.destroyed?

        character.notifications.schedule(:market_item_sold,
          :item_id      => inventory.item_id,
          :basic_money  => basic_money,
          :vip_money    => vip_money
        )
      end
    end
  end

  def event_data(bought)
    {
      :reference_id   => id,
      :reference_type => "MarketItem",
      :string_value   => name,
      :basic_money    => (bought ? -1 : 1) * basic_price,
      :vip_money      => (bought ? -1 : 1) * vip_price,
      :amount         => amount
    }
  end
  
  def requirements
    @requirements ||= Requirements::Collection.new(
      Requirements::BasicMoney.new(:value => basic_price),
      Requirements::VipMoney.new(:value => vip_price)
    )
  end

  protected

  def vip_price_dont_more_than_max
    if vip_price
      max_vip_price = inventory.item.max_vip_price_in_market || 0
       
      if vip_price > max_vip_price
        errors.add(:vip_price, :less_than_or_equal_to, :count => max_vip_price)
      end
    end
  end

  def check_amount
    if amount.to_i > inventory.amount
      errors.add(:amount, :less_than_or_equal_to, :count => inventory.amount)
    end
  end
  
  def item_allowed_to_sell
    errors.add(:item, :not_allowed_to_sell) unless inventory.can_be_sold_on_market?
  end

  def destroy_previous_items
    self.class.destroy_all(:inventory_id => inventory.id)
  end

  def assign_character
    self.character = inventory.character
  end
end
