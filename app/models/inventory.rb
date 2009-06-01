class Inventory < ActiveRecord::Base
  PLACEMENTS = [:head, :body, :left_hand, :right_hand, :belt, :legs]

  belongs_to :character
  belongs_to :item

  named_scope :by_item_group, Proc.new{|group|
    {
      :conditions => ["items.item_group_id = ?", group.id],
      :include    => :item,
      :order      => "items.level ASC, items.basic_price ASC"
    }
  }

  named_scope :placed, { :conditions => "placement IS NOT NULL" }

  delegate :name, :description, :image, :effects, :placements, :placeable?, :usable?, :usage_limit, :to => :item
  
  attr_accessor :free_of_charge

  validate_on_create :enough_character_money?

  after_create  :charge_character
  after_destroy :recache_character_effects

  def sell_price
    (self.item.basic_price * 0.8).ceil
  end

  def place_to(placement)
    if self.placements.include?(placement.to_s) and placement != self.placement
      self.class.transaction do
        self.character.inventories.update_all('placement = NULL', ['placement = ?', placement])
        
        self.update_attribute(:placement, placement)

        self.recache_character_effects
      end
    end
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
        self.destroy
      else
        self.save!
      end
    end
  end

  def sell
    self.transaction do
      self.character.basic_money += self.sell_price
      self.character.save!

      self.destroy
    end
  end
  
  protected

  def enough_character_money?
    return if self.free_of_charge
    
    self.errors.add(:character, :not_enough_money) unless self.character.can_buy?(self.item)
  end

  def charge_character
    return if self.free_of_charge

    self.transaction do
      self.character.basic_money  -= self.item.basic_price if self.item.basic_price.to_i > 0
      self.character.vip_money    -= self.item.vip_price if self.item.vip_price.to_i > 0
      
      self.character.save!
    end
  end

  def recache_character_effects
    self.character.cache_inventory_effects
  end
end
