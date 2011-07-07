class Inventory < ActiveRecord::Base
  belongs_to  :character
  belongs_to  :item
  has_one     :market_item, :dependent => :destroy

  named_scope :by_item_group, Proc.new{|group|
    {
      :conditions => ["items.item_group_id = ?", group.id],
      :include    => :item,
      :order      => "items.level ASC, items.basic_price ASC"
    }
  }
  named_scope :equipped, :conditions => "equipped > 0"
  named_scope :equippable,
    :include => :item,
    :conditions => "items.equippable = 1 AND (inventories.equipped < inventories.amount)"

  delegate(
    *(
      Item::EFFECTS +
      %w{
        item_group  name plural_name description image image?
        basic_price vip_price can_be_sold? can_be_sold_on_market?
        placements placement_options_for_select
        payouts payouts? use_button_label use_message effects effects? boost?
        boost_type
      } +
      [{:to => :item}]
    )
  )

  attr_accessor :charge_money, :deposit_money, :basic_money, :vip_money

  validate :enough_character_money?
  validates_numericality_of :amount, :greater_than => 0

  before_save   :charge_or_deposit_character
  after_update  :check_market_items
  after_destroy :deposit_character

  def sell_price
    Setting.p(:inventory_sell_price, item.basic_price).ceil
  end
  
  def usable?
    !frozen? && item.usable?
  end

  def use!
    return false unless usable?

    transaction do
      payouts.apply(character, :use, item).tap do
        character.inventories.take!(self)
      end
    end
  end

  def amount_available_for_equipment
    amount - equipped
  end

  def equippable?
    item.equippable? and amount_available_for_equipment > 0
  end

  def equipped?
    equipped > 0
  end
  
  def requirements
    item.requirements(purchase_amount)
  end
  
  def purchase_amount
    changes["amount"] ? (changes["amount"].last - changes["amount"].first) / item.package_size : 0
  end

  protected

  def enough_character_money?
    return unless charge_money && purchase_amount > 0

    errors.add(:character, :not_enough_basic_money, :name => name) if character.basic_money < basic_price * purchase_amount
    errors.add(:character, :not_enough_vip_money, :name => name) if character.vip_money < vip_price * purchase_amount
  end

  def charge_or_deposit_character
    return unless changes["amount"]

    if purchase_amount > 0 # Buying items, should charge
      if charge_money
        self.basic_money = basic_price * purchase_amount
        self.vip_money = vip_price * purchase_amount

        character.charge(basic_money, vip_money, item)
      end
    else # Selling items, should deposit
      deposit_character(purchase_amount.abs)
    end
  end

  def deposit_character(amount = nil)
    amount ||= self.amount

    if deposit_money
      self.basic_money = sell_price * amount

      character.charge(- basic_money, 0, item)
    end
  end
  
  def check_market_items
    if market_item and market_item.amount > amount
      market_item.destroy
    end
  end
end
