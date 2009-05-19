class Character < ActiveRecord::Base
  extend SerializeWithPreload

  LEVELS = [0]

  200.times do |i|
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
  has_many :items, :through => :inventories
  has_many :relations, :foreign_key => "source_id"
  has_many :properties, :order => "property_type_id"
  
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

  serialize :inventory_effects, Effects::Collection

  extend RestorableAttribute
  restorable_attribute :hp, :limit => :health, :restore_period => 2.minutes + 30.seconds
  restorable_attribute :ep, :limit => :energy, :restore_period => 5.minutes

  before_save :update_level_and_points, :recalculate_rating

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

  def need_vip_money?(item)
    item.vip_price.to_i > 0 && self.vip_money < item.vip_price
  end

  def can_attack?(victim)
    not self.class.victims_for(self).find_by_id(victim.id).nil?
  end

  def can_fulfill?(mission)
    self.ep >= mission.ep_cost && 
    mission.requirements.satisfies?(self) &&
    !self.rank_for_mission(mission).completed?
  end

  def rank_for_mission(mission)
    self.ranks.find_or_initialize_by_mission_id(mission.id)
  end

  protected

  def update_level_and_points
    if self.experience_to_next_level <= 0
      self.level  += 1
      self.points += 5

      self.level_updated = true
    end
  end

  def recalculate_rating
    self.rating = (
      self.missions_completed * 500 +
      self.relations_count    * 100 +
      self.fights_won         * 10 +
      self.missions_succeeded * 5
    )
  end
end
