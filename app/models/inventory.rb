class Inventory < ActiveRecord::Base
  PLACEMENTS = [:head, :body, :left_hand, :right_hand, :belt, :legs]

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

  named_scope :placed, { :conditions => "placement IS NOT NULL" }

  validate_on_create :enough_character_money?

  after_create  :charge_character
  after_destroy :deposit_character
  before_save   :cleanup_placement

  delegate :name, :description, :attack, :defence, :image, :to => :item
  
  def sell_price
    (self.item.price * 0.8).ceil
  end

  def possible_placements
    self.item.placements.split(",")
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

  def cleanup_placement
    if self.placement_changed? and !self.placement.blank?
      self.character.inventories.update_all('placement = NULL', ['placement = ?', self.placement])
    end
  end
end
