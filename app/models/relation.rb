class Relation < ActiveRecord::Base
  belongs_to  :source_character, :foreign_key => "source_id", :class_name => "Character", :counter_cache => true
  has_many    :holded_inventories, :class_name => "Inventory", :as => :holder

  serialize :inventory_effects, Effects::Collection

  after_destroy :displace_holded_inventories

  def inventory_effects
    super || Effects::Collection.new
  end

  def cache_inventory_effects
    self.inventory_effects = Effects::Collection.new

    self.holded_inventories.each do |item|
      self.inventory_effects << item.effects
    end

    self.save

    self.recache_character_effects
  end

  def attack_points
    self.inventory_effects[:attack].value
  end

  def defence_points
    self.inventory_effects[:defence].value
  end

  def recache_character_effects
    self.source_character.cache_relation_effects
  end

  def displace_holded_inventories
    self.holded_inventories.update_all("holder_id = NULL, holder_type = NULL, placement = NULL")

    self.recache_character_effects
  end
end
