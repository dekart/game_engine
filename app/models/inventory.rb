class Inventory < ActiveRecord::Base
  belongs_to :character
  belongs_to :item

  named_scope :weapons, {:conditions => "items.type = 'Weapon'", :include => :item}
  named_scope :armors, {:conditions => "items.type = 'Armor'", :include => :item}

  validate_on_create :enough_character_money?

  after_create :charge_character
  after_destroy :deposit_character

  delegate :name, :description, :attack, :defence, :to => :item
  
  def price
    (self.item.price * 0.7).ceil
  end
  
  protected

  def enough_character_money?
    self.errors.add(:character, "Not enough money") if self.character.money < self.item.price
  end

  def charge_character
    self.character.decrement!(:money, self.item.price)
  end

  def deposit_character
    self.character.increment!(:money, self.price)
  end
end
