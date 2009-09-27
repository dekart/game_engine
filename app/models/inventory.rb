class Inventory < ActiveRecord::Base
  belongs_to :character
  belongs_to :item

  named_scope :by_item_group, Proc.new{|group|
    {
      :conditions => ["items.item_group_id = ?", group.id],
      :include    => :item,
      :order      => "items.level ASC, items.basic_price ASC"
    }
  }
  named_scope :used_in_fight, :conditions => "use_in_fight > 0"

  %w{
    name description image image? basic_price vip_price attack defence effects
    usable? usage_limit can_be_sold?
  }.each do |attr|
    delegate attr, :to => :item
  end
  
  attr_accessor :charge_money, :deposit_money, :money_return

  validate :enough_character_money?

  before_save :charge_or_deposit_character
  after_destroy :deposit_character

  def sell_price
    (self.item.basic_price * 0.5).ceil
  end

  def uses_left
    self.usage_limit - self.usage_count
  end

  def use
    return unless self.usable?

    self.transaction do
      self.effects.apply(self.character)
      self.character.save!

      self.usage_count += 1

      if self.uses_left == 0
        self.character.inventories.take!(self.item)
        self.usage_count = 0
      end
      
      self.save!
    end
  end

  protected

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
