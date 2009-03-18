class Inventory < ActiveRecord::Base
  belongs_to :character
  belongs_to :item

  named_scope :weapons, {
    :conditions => "items.type = 'Weapon'",
    :include    => :item,
    :order      => "items.attack DESC"
  }
  named_scope :armors, {
    :conditions => "items.type = 'Armor'",
    :include    => :item,
    :order      => "items.defence DESC"
  }

  validate_on_create :enough_character_money?

  after_create :charge_character
  after_destroy :deposit_character

  delegate :name, :description, :attack, :defence, :to => :item
  
  def sell_price
    (self.item.price * 0.8).ceil
  end
  
  protected

  def enough_character_money?
    self.errors.add(:character, "You don't have enough money to buy {item_name}") if self.character.basic_money < self.item.price
  end

  def charge_character
    self.character.decrement!(:basic_money, self.item.price)
  end

  def deposit_character
    self.character.increment!(:basic_money, self.sell_price)
  end
end
