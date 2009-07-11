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

  MONEY_EXCHANGE_RATE = {
    :basic_money => 1000,
    :vip_money   => 5
  }
  ENERGY_REFILL_RATE = 5
  HEALTH_REFILL_RATE = 1
  BUY_POINTS_RATE = {
    :vip_money  => 5,
    :points     => 5
  }

  belongs_to :user
  has_many :ranks do
    def completed_mission_ids
      find(:all, :select => "mission_id", :conditions => {:completed => true}).collect{|m| m.mission_id}
    end
  end
  has_many :missions, :through => :ranks
  
  has_many :inventories, :include => :item, :order => "items.level, items.id"
  has_many :holded_inventories, :class_name => "Inventory", :as => :holder
  
  has_many :items, :through => :inventories
  has_many :relations, :foreign_key => "source_id" do
    def facebook_ids
      find(:all, :include => {:target_character => :user}).collect{|r| r.target_character.user.facebook_id}
    end

    def established?(character)
      find(:first, :conditions => ['target_id = ?', character.id])
    end
  end
  has_many :properties, :order => "property_type_id"
  
  has_many :attacks, :class_name => "Fight", :foreign_key => :attacker_id
  has_many :defences, :class_name => "Fight", :foreign_key => :victim_id
  has_many :won_fights, :class_name => "Fight", :foreign_key => :winner_id

  has_many :assignments, :as => :context, :extend => AssignmentExtension

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
          :high_level   => attacker.level + 5,
          :attacker_id  => attacker.id,
          :time_limit   => 1.hour.ago
        }
      ],
      :include  => :user
    }
  }

  attr_accessor :level_updated

  serialize :inventory_effects, Effects::Collection
  serialize :relation_effects, Effects::Collection

  extend RestorableAttribute
  restorable_attribute :hp, :limit => :health, :restore_period => 2.minutes + 30.seconds
  restorable_attribute :ep, :limit => :energy, :restore_period => 5.minutes
  restorable_attribute :basic_money, :restore_period => 1.hour, :restore_rate => :property_income

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
    self.own_attack_points + self.relation_effects[:attack].value + self.assignments.effect_value(:attack)
  end

  def defence_points
    self.own_defence_points + self.relation_effects[:defence].value + self.assignments.effect_value(:defence)
  end

  def own_attack_points
    self.attack + self.inventory_effects[:attack].value
  end
  
  def own_defence_points
    self.defence + self.inventory_effects[:defence].value
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

  def level_progress_percentage
    (100 - self.experience_to_next_level.to_f / (self.next_level_experience - LEVELS[self.level - 1]) * 100).round
  end

  def to_json(options = {})
    super(
      :only     => [:basic_money, :vip_money, :experience, :level, :energy, :ep, :health, :hp, :points],
      :methods  => [
        :next_level_experience,
        :level_progress_percentage,
        :time_to_hp_restore,
        :time_to_ep_restore,
        :time_to_basic_money_restore
      ]
    )
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
  end

  def relation_effects
    super || Effects::Collection.new
  end

  def cache_relation_effects
    self.relation_effects = Effects::Collection.new

    self.relations.each do |relation|
      self.relation_effects << relation.inventory_effects
    end

    self.save
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

  def recalculate_income
    self.basic_money = self.basic_money

    self.property_income = 0

    self.properties.each do |property|
      self.property_income += property.income
    end

    self.save
  end

  def rating_position
    self.class.count(:conditions => ["rating > ?", self.rating]) + 1
  end

  def exchange_money!
    return if self.vip_money < MONEY_EXCHANGE_RATE[:vip_money]

    self.class.transaction do
      self.vip_money    -= MONEY_EXCHANGE_RATE[:vip_money]
      self.basic_money  += MONEY_EXCHANGE_RATE[:basic_money]

      self.save
    end
  end

  def full_energy?
    self.ep == self.energy
  end

  def refill_energy!(free = false)
    return if full_energy? or (!free and vip_money < ENERGY_REFILL_RATE)

    self.class.transaction do
      self.ep = self.energy
      self.vip_money -= ENERGY_REFILL_RATE unless free

      self.save
    end
  end

  def full_health?
    self.hp == self.health
  end

  def refill_health!(free = false)
    return if full_health? or (!free and vip_money < HEALTH_REFILL_RATE)

    self.class.transaction do
      self.hp = self.health
      self.vip_money -= HEALTH_REFILL_RATE unless free

      self.save
    end
  end

  def buy_points!
    return if self.vip_money < BUY_POINTS_RATE[:vip_money]

    self.class.transaction do
      self.vip_money  -= BUY_POINTS_RATE[:vip_money]
      self.points     += BUY_POINTS_RATE[:points]

      self.save
    end
  end

  def owner
    self
  end

  protected

  def update_level_and_points
    if self.experience_to_next_level <= 0
      self.level  += 1
      self.points += 5
      self.ep     = self.energy
      self.hp     = self.health

      self.level_updated = true
    end
  end

  def recalculate_rating
    self.rating = (
      self.missions_completed * 500 +
      self.relations_count    * 100 +
      self.fights_won         * 10 +
      self.missions_succeeded * 5 +
      (self.property_income.to_f / (5 + self.property_income.to_f / 50000)).ceil
    )
  end
end
