class Relation < ActiveRecord::Base
  belongs_to  :source_character, :foreign_key => "source_id", :class_name => "Character", :counter_cache => true
  belongs_to  :target_character, :foreign_key => "target_id", :class_name => "Character"
  has_one     :assignment, :dependent => :destroy
  has_many    :holded_inventories, :class_name => "Inventory", :as => :holder

  named_scope :not_assigned,
    :include    => [:assignment, :target_character],
    :conditions => "assignments.id IS NULL"
  named_scope :assigned, 
    :include    => [:assignment, :target_character],
    :conditions => "assignments.id IS NOT NULL"

  serialize :inventory_effects, Effects::Collection

  validates_uniqueness_of :target_id, :scope => :source_id

  after_destroy :displace_holded_inventories

  def self.destroy_between(c1, c2)
    self.transaction do
      Relation.find(:all,
        :conditions => [
          "(source_id = :c1 AND target_id = :c2) OR (source_id = :c2 AND target_id = :c1)",
          {
            :c1 => c1,
            :c2 => c2
          }
        ]
      ).each do |relation|
        relation.destroy
      end

      Invitation.find(:all, :conditions => [
          "(sender_id = :c1 AND receiver_id = :u2) OR (sender_id = :c2 AND receiver_id = :u1)",
          {
            :c1 => c1,
            :c2 => c2,
            :u1 => c1.user.facebook_id,
            :u2 => c2.user.facebook_id
          }
        ]
      ).each do |invitation|
        invitation.destroy
      end
    end
  end

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
