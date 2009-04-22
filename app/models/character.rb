require "effects/base"

class Character < ActiveRecord::Base
  LEVELS = [0]

  70.times do |i|
    LEVELS[i + 1] = LEVELS[i].to_i + (i + 1) * 10
  end

  UPGRADES = {
    :attack   => 1,
    :defence  => 1,
    :health   => 5,
    :energy   => 1
  }

  belongs_to :user
  has_many :ranks
  has_many :missions, :through => :ranks
  has_many :inventories, :include => :item
  has_many :relations, :foreign_key => "source_id"
  
  has_many :attacks, :class_name => "Fight", :foreign_key => :attacker_id
  has_many :defences, :class_name => "Fight", :foreign_key => :victim_id
  has_many :won_fights, :class_name => "Fight", :foreign_key => :winner_id

  named_scope :victims_for, Proc.new{|attacker|
    {
      :conditions => [
        %{
          (level BETWEEN :low_level AND :high_level) AND
          characters.id NOT IN (
            SELECT fights.victim_id FROM fights WHERE attacker_id = :attacker_id AND winner_id = :attacker_id AND fights.created_at > :time_limit
          ) AND
          characters.id != :attacker_id
        },
        {
          :low_level    => attacker.level,
          :high_level   => attacker.level + 2,
          :attacker_id  => attacker.id,
          :time_limit   => 1.hour.ago
        }
      ],
      :include  => :user
    }
  }

  attr_accessor :level_updated

  extend SerializeEffects
  serialize_effects :inventory_effects

  extend RestorableAttribute
  restorable_attribute :hp, :health, 2.minutes + 30.seconds
  restorable_attribute :ep, :energy, 5.minutes

  before_save :update_level_and_points

  def upgrade_attribute!(name)
    name = name.to_sym

    return false unless UPGRADES.keys.include?(name) && self.points > 0

    ActiveRecord::Base.transaction do
      case name
      when :health
        self.health += UPGRADES[:health]
        self.hp     += UPGRADES[:health]
      when :energy
        self.energy += UPGRADES[:energy]
        self.ep     += UPGRADES[:energy]
      else
        self.increment(name, UPGRADES[name.to_sym])
      end

      self.decrement(:points)

      self.save
    end

    return true
  end

  def attack_points
    self.attack + self.inventory_effects[:attack].value + self.relations.size
  end

  def defence_points
    self.defence + self.inventory_effects[:defence].value + self.relations.size
  end

  def weak?
    self.hp < self.weakness_minimum
  end

  def weakness_minimum
    (self.health * 0.2).ceil
  end

  def experience_to_next_level
    self.next_level_experience - self.experience
  end

  def next_level_experience
    LEVELS[self.level]
  end

  def to_json(options = {})
    super(
      :only     => [:basic_money, :vip_money, :experience, :level, :energy, :ep, :health, :hp, :points],
      :methods  => [:next_level_experience, :time_to_hp_restore, :time_to_ep_restore]
    )
  end

  def cache_inventory_effects
    self.inventory_effects = Effects::Collection.new

    self.inventories.placed.each do |item|
      self.inventory_effects << item.effects
    end

    self.save
  end

  def inventory_effects
    self[:inventory_effects] ||= Effects::Collection.new
  end

  def can_buy?(item)
    self.basic_money >= item.basic_price.to_i and self.vip_money >= item.vip_price.to_i
  end

  protected

  def update_level_and_points
    if self.experience_to_next_level <= 0
      self.level  += 1
      self.points += 5

      self.level_updated = true
    end
  end
#
#  def update_hp_and_ep
#    self.hp_updated_at = Time.now if hp_changed?
#    self.ep_updated_at = Time.now if ep_changed?
#  end
end
