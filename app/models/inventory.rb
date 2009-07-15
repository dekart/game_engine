class Inventory < ActiveRecord::Base
  PLACEMENTS = [:head, :body, :left_hand, :right_hand, :belt, :legs]
  PLACEMENT_IMAGES = {
    :head       => :small,
    :left_hand  => :medium,
    :right_hand => :medium,
    :body       => :medium,
    :legs       => :medium,
    :belt       => :belt
  }

  belongs_to :character
  belongs_to :item
  belongs_to :holder, :polymorphic => true

  named_scope :by_item_group, Proc.new{|group|
    {
      :conditions => ["items.item_group_id = ?", group.id],
      :include    => :item,
      :order      => "items.level ASC, items.basic_price ASC"
    }
  }
  named_scope :available, :conditions => "holder_id IS NULL"

  delegate :name, :description, :image, :effects, :placements, :placeable?, :usable?, :usage_limit, :to => :item
  
  attr_accessor :free_of_charge

  validate_on_create :enough_character_money?

  after_create  :charge_character
  after_destroy :recache_holder_effects

  def sell_price
    (self.item.basic_price * 0.5).ceil
  end

  def place_to(placement, new_holder)
    if self.placements.include?(placement.to_s) and placement != self.placement
      self.class.transaction do

        self.character.inventories.update_all(
          'placement = NULL, holder_id = NULL, holder_type = NULL',
          [
            'placement = :p_id AND holder_id = :h_id AND holder_type = :h_t',
            {
              :p_id => placement,
              :h_id => new_holder.id,
              :h_t  => new_holder.class.to_s #FIXME We should use  inheritance column value used by activerecord itself instead of simple class name
            }
          ]
        )
        
        self.update_attributes(
          :placement  => placement,
          :holder     => new_holder
        )

        self.recache_holder_effects
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

  def take_off!
    self.transaction do
      @previous_holder = self.holder
      
      self.update_attributes(:holder => nil, :placement => nil)

      self.recache_holder_effects
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

  def recache_holder_effects
    return unless recache = (self.holder || @previous_holder)

    recache.cache_inventory_effects
  end
end
