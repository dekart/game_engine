class Character < ActiveRecord::Base
  extend SerializeWithPreload
  extend RestorableAttribute
  include ActionView::Helpers::NumberHelper 
  
  LEVELS = [0]

  1000.times do |i|
    LEVELS[i + 1] = ((LEVELS[i].to_i * 1.02 + (i + 1) * 10).round / 10.0).round * 10
  end

  UPGRADABLE_ATTRIBUTES = [:attack, :defence, :health, :energy, :stamina]

  belongs_to :user
  belongs_to :character_type,
    :counter_cache => true
  
  has_many :ranks,
    :dependent => :delete_all
  has_many :missions, 
    :through  => :ranks,
    :extend   => Character::Missions

  has_many :mission_group_ranks, :dependent => :delete_all
  has_many :mission_groups, 
    :through  => :mission_group_ranks,
    :extend   => Character::MissionGroups
  
  has_many :inventories,
    :include    => :item,
    :dependent  => :delete_all,
    :extend     => Character::Inventories
  
  has_many :items, :through => :inventories
  
  has_many :relations, 
    :foreign_key  => "source_id",
    :extend       => Character::Relations
  has_many :friend_relations, 
    :foreign_key  => "source_id",
    :include      => :target_character,
    :dependent    => :destroy,
    :extend       => Character::FriendRelations
  has_many :reverse_friend_relations, 
    :foreign_key  => "target_id",
    :class_name   => "FriendRelation",
    :dependent    => :destroy
  has_many :mercenary_relations, 
    :foreign_key  => "source_id",
    :dependent    => :delete_all,
    :extend       => Character::MercenaryRelations

  has_many :properties,
    :order      => "property_type_id",
    :dependent  => :delete_all,
    :extend     => Character::Properties
  
  has_many :attacks, 
    :class_name   => "Fight",
    :foreign_key  => :attacker_id,
    :dependent    => :delete_all
  has_many :defences, 
    :class_name   => "Fight",
    :foreign_key  => :victim_id,
    :dependent    => :delete_all
  has_many :won_fights, 
    :class_name   => "Fight",
    :foreign_key  => :winner_id

  has_many :assignments,
    :as         => :context,
    :dependent  => :delete_all,
    :extend     => Character::Assignments

  has_many :help_requests, 
    :dependent  => :destroy,
    :extend     => Character::HelpRequests

  has_many :gifts

  has_many :boss_fights,
    :extend => Character::BossFights

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
          :low_level    => attacker.level - Setting.i(:fight_victim_levels_lower),
          :high_level   => attacker.level + Setting.i(:fight_victim_levels_higher),
          :attacker_id  => attacker.id,
          :time_limit   => Setting.i(:fight_attack_repeat_delay).minutes.ago
        }
      ],
      :include  => :user
    }
  }

  named_scope :rated_by, Proc.new{|unit|
    {
      :order => "characters.#{unit} DESC",
      :limit => Setting.i(:rating_show_limit)
    }
  }

  serialize :placements

  attr_accessible :name

  attr_accessor :level_updated

  restorable_attribute :hp,
    :limit          => :health,
    :restore_period => Setting.i(:character_health_restore_period).seconds,
    :restore_bonus  => :health_restore_bonus
  restorable_attribute :ep, 
    :limit          => :energy,
    :restore_period => Setting.i(:character_energy_restore_period).seconds,
    :restore_bonus  => :energy_restore_bonus
  restorable_attribute :sp,
    :limit          => :stamina,
    :restore_period => Setting.i(:character_stamina_restore_period).seconds,
    :restore_bonus  => :stamina_restore_bonus
  restorable_attribute :basic_money, 
    :restore_period => Setting.i(:character_income_calculation_period).minutes,
    :restore_rate   => :property_income,
    :restore_bonus  => :income_period_bonus

  before_create :apply_character_type_defaults
  before_save   :update_level_and_points

  validates_presence_of :character_type, :on => :create

  class << self
    def find_by_invitation_key(key)
      id, secret = key.split("-")

      if character = find_by_id(id) and secret == character.secret
        character
      else
        nil
      end
    end

    def find_by_key(key)
      id, secret = key.split("-")

      if character = find_by_id(id) and secret == character.secret(10)
        character
      else
        nil
      end
    end

    def rating_position(character, field)
      self.count(
        :conditions => ["#{field} > ?", character.send(field)]
      ) + 1
    end

    def level_for_experience(value)
      LEVELS.each_with_index do |experience, level|
        return level if experience >= value
      end
    end
  end

  def self_and_relations
    Character.scoped(
      :conditions => {
        :id => [id] + self.friend_relations.character_ids
      }
    )
  end

  def upgrade_attribute!(name)
    name = name.to_sym

    return false unless UPGRADABLE_ATTRIBUTES.include?(name) && self.points >= Setting.i("character_#{name}_upgrade_points")

    ActiveRecord::Base.transaction do
      case name
      when :health
        self.health += Setting.i(:character_health_upgrade)
        self.hp     += Setting.i(:character_health_upgrade)
      when :energy
        self.energy += Setting.i(:character_energy_upgrade)
        self.ep     += Setting.i(:character_energy_upgrade)
      when :stamina
        self.stamina  += Setting.i(:character_stamina_upgrade)
        self.sp       += Setting.i(:character_stamina_upgrade)
      else
        self.increment(name, Setting.i("character_#{name}_upgrade"))
      end

      self.points -= Setting.i("character_#{name}_upgrade_points")

      self.save
    end

    return true
  end

  def attack_points
    self.attack + self.inventory_attack_points + self.assignments.effect_value(:attack)
  end

  def defence_points
    self.defence + self.inventory_defence_points + self.assignments.effect_value(:defence)
  end

  def inventory_attack_points
    inventories.equipped.all.sum{|i| i.equipped * i.attack }
  end

  def inventory_defence_points
    inventories.equipped.all.sum{|i| i.equipped * i.defence }
  end

  def fight_damage_reduce
    assignments.effect_value(:fight_damage)
  end

  def weak?
    self.hp < self.weakness_minimum
  end

  def weakness_minimum
    Setting.p(:character_weakness_minimum, health)
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

  def formatted_basic_money
    number_to_currency(basic_money)
  end

  def formatted_vip_money
    number_to_currency(vip_money)
  end

  def to_json_for_overview(options = {})
    to_json(
      :only     => [
        :basic_money, :vip_money, :experience, :level, :energy, :ep, :health, :hp,
        :stamina, :sp, :points, :property_income
      ],
      :methods  => [
        :formatted_basic_money,
        :formatted_vip_money,
        :next_level_experience,
        :level_progress_percentage,
        :time_to_hp_restore,
        :time_to_ep_restore,
        :time_to_sp_restore,
        :time_to_basic_money_restore
      ]
    )
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
    MissionResult.new(self, mission).valid?
  end

  def rank_for_mission(mission)
    self.ranks.find_or_initialize_by_mission_id(mission.id)
  end

  def recalculate_income
    self.reload
    
    self.basic_money = self.basic_money

    self.property_income = self.properties.inject(0) do |result, property|
      result += property.total_income
    end

    self.save
  end

  def exchange_money!
    return if self.vip_money < Setting.i(:premium_money_price)

    self.class.transaction do
      self.vip_money    -= Setting.i(:premium_money_price)
      self.basic_money  += Setting.i(:premium_money_amount)

      self.save
    end
  end

  def full_energy?
    self.ep == self.energy
  end

  def refill_energy!(free = false)
    return if full_energy? or (!free and vip_money < Setting.i(:premium_energy_price))

    self.class.transaction do
      self.ep = self.energy
      self.vip_money -= Setting.i(:premium_energy_price) unless free

      self.save
    end
  end

  def full_health?
    self.hp == self.health
  end

  def refill_health!(free = false)
    return if full_health? or (!free and vip_money < Setting.i(:premium_health_price))

    self.class.transaction do
      self.hp = self.health
      self.vip_money -= Setting.i(:premium_health_price) unless free

      self.save
    end
  end

  def full_stamina?
    self.sp == self.stamina
  end

  def refill_stamina!(free = false)
    return if full_stamina? or (!free and vip_money < Setting.i(:premium_stamina_price))

    self.class.transaction do
      self.sp = self.health
      self.vip_money -= Setting.i(:premium_stamina_price) unless free

      self.save
    end
  end

  def buy_points!
    return if self.vip_money < Setting.i(:premium_points_price)

    self.class.transaction do
      self.vip_money  -= Setting.i(:premium_points_price)
      self.points     += Setting.i(:premium_points_amount)

      self.save
    end
  end

  def hire_mercenary!
    return if self.vip_money < Setting.i(:premium_mercenary_price)

    self.transaction do
      self.vip_money -= Setting.i(:premium_mercenary_price)
      
      mercenary_relations.create!
      save
    end
  end

  def owner
    self
  end

  def allow_fight_with_invite?
    Setting.b(:fight_with_invite_allowed) and
      level <= Setting.i(:fight_with_invite_max_level)
  end

  def secret(length = 5)
    Digest::MD5.hexdigest("#{self.id}-#{self.created_at}")[0, length]
  end

  def invitation_key
    "#{id}-#{secret}"
  end

  def key
    "#{id}-#{secret(10)}"
  end

  def charge(basic_amount, vip_amount)
    self.basic_money  -= basic_amount if basic_amount > 0
    self.vip_money    -= vip_amount if vip_amount > 0

    self.save
  end

  def titles
    (self.ranks.completed + self.mission_group_ranks.completed).collect do |rank|
      rank.title unless rank.title.blank?
    end.compact
  end

  def personalize_from(facebook_session)
    profile_info = facebook_session.users([self.user.facebook_id], [:name]).first

    self.name = profile_info.name if self.name.blank?
  end

  CharacterType::BONUSES.each do |bonus|
    define_method(bonus) do
      character_type.try(bonus)
    end
  end

  def equipment
    @equipment ||= Character::Equipment.new(self)
  end

  def placements
    self[:placements] ||= {}
  end

  protected

  def update_level_and_points
    if self.experience_to_next_level <= 0
      self.level      += 1
      
      self.points     += Setting.i(:character_points_per_upgrade)
      self.vip_money  += Setting.i(:character_vip_money_per_upgrade)

      self.ep     = self.energy
      self.hp     = self.health

      self.level_updated = true
    end
  end

  def apply_character_type_defaults
    CharacterType::APPLICABLE_ATTRIBUTES.each do |attribute|
      self.send("#{attribute}=", character_type.send(attribute))
    end

    self.hp = self.health
    self.ep = self.energy
    self.sp = self.stamina
  end
end
