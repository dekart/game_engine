class Inventory < ActiveRecord::Base
  PLACEMENTS = [:head, :body, :left_hand, :right_hand, :belt, :legs]

  belongs_to :character
  belongs_to :item

  named_scope :weapons, {
    :conditions => "items.type = 'Weapon'",
    :include    => :item,
    :order      => "items.level ASC"
  }
  named_scope :armors, {
    :conditions => "items.type = 'Armor'",
    :include    => :item,
    :order      => "items.level ASC"
  }

  named_scope :placed, { :conditions => "placement IS NOT NULL" }

  validate_on_create :enough_character_money?

  after_create  :charge_character
  after_destroy :deposit_character

  delegate :name, :description, :image, :effects, :to => :item
  
  def sell_price
    (self.item.price * 0.8).ceil
  end

  def possible_placements
    self.item.placements.split(",")
  end

  def apply_to(placement)
    if self.possible_placements.include?(placement.to_s)

      self.class.transaction do
        self.character.inventories.update_all('placement = NULL', ['placement = ?', self.placement])
        
        self.update_attribute(:placement, placement)

        self.character.cache_inventory_effects
      end
    end
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
