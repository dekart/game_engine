class Character < ActiveRecord::Base
  extend SerializeWithPreload
  extend RestorableAttribute
  extend HasPayouts
  include ActionView::Helpers::NumberHelper
  
  include Character::Levels
  include Character::Relations
  include Character::Inventories
  include Character::Properties
  include Character::Gifts
  include Character::Notifications
  include Character::Titles
  include Character::Missions
  include Character::Collections
  include Character::Newsfeed
  include Character::Hospital
  include Character::Monsters
  include Character::Premium


  UPGRADABLE_ATTRIBUTES = [:attack, :defence, :health, :energy, :stamina]

  belongs_to :user
  belongs_to :character_type,
    :counter_cache => true

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
    :dependent  => :delete_all

  has_many :help_requests,
    :dependent  => :destroy,
    :extend     => Character::HelpRequests

  has_many :boss_fights,
    :extend => Character::BossFights

  has_many :ordered_hit_listings, :foreign_key => :client_id, :class_name => "HitListing"

  has_many :bank_deposits
  has_many :bank_withdrawals, :class_name => "BankWithdraw"

  has_many :vip_money_deposits
  has_many :vip_money_withdrawals

  has_many :market_items

  has_many :wall_posts

  named_scope :rated_by, Proc.new{|unit|
    {
      :order => "characters.#{unit} DESC",
      :limit => Setting.i(:rating_show_limit)
    }
  }

  serialize :placements

  attr_accessible :name

  has_payouts :save

  restorable_attribute :hp,
    :limit          => :health_points,
    :restore_period => :health_restore_period,
    :restore_bonus  => :health_restore_bonus
  restorable_attribute :ep,
    :limit          => :energy_points,
    :restore_period => :energy_restore_period,
    :restore_bonus  => :energy_restore_bonus
  restorable_attribute :sp,
    :limit          => :stamina_points,
    :restore_period => :stamina_restore_period,
    :restore_bonus  => :stamina_restore_bonus

  after_validation_on_create :apply_character_type_defaults
  before_save   :update_level_and_points, :update_total_money

  validates_presence_of :character_type, :on => :create

  delegate(*(CharacterType::BONUSES + [:to => :character_type]))

  class << self
    def find_by_invitation_key(key)
      if character = find_by_id(key.split("-").first) and key.downcase == character.invitation_key
        character
      else
        nil
      end
    end

    def find_by_key(key)
      if character = find_by_id(key.split("-").first) and key.downcase == character.key
        character
      else
        nil
      end
    end

    def rating_position(character, field)
      count(:conditions => ["#{field} > ?", character.send(field)]) + 1
    end
  end

  def basic_money=(value)
    self[:basic_money] = [value.to_i, 0].max
  end

  def vip_money=(value)
    self[:vip_money] = [value.to_i, 0].max
  end

  def self_and_relations
    self.class.scoped(:conditions => {:id => [id] + friend_relations.character_ids})
  end

  def upgrade_attribute!(name)
    name = name.to_sym

    return false unless UPGRADABLE_ATTRIBUTES.include?(name) && points >= Setting.i("character_#{name}_upgrade_points")

    transaction do
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
        increment(name, Setting.i("character_#{name}_upgrade"))
      end

      self.points -= Setting.i("character_#{name}_upgrade_points")

      save
    end
  end

  def attack_points
    attack + 
      equipment.effect(:attack) +
      assignments.attack_effect +
      boosts.best_attacking.try(:attack).to_i
  end

  def defence_points
    defence +
      equipment.effect(:defence) +
      assignments.defence_effect +
      boosts.best_defending.try(:defence).to_i
  end

  def health_points
    health + equipment.effect(:health)
  end

  def energy_points
    energy + equipment.effect(:energy)
  end

  def stamina_points
    stamina + equipment.effect(:stamina)
  end

  def fight_damage_reduce
    assignments.fight_damage_effect
  end

  def weak?
    hp < weakness_minimum
  end
  
  def weakness_requirement
    Requirements::HealthPoint.new(:value => weakness_minimum)
  end

  def weakness_minimum
    Setting.p(:character_weakness_minimum, health).to_i
  end

  def formatted_basic_money
    number_to_currency(basic_money)
  end

  def formatted_vip_money
    number_to_currency(vip_money)
  end

  def to_json_for_overview
    to_json(
      :only => [
        :basic_money,
        :vip_money,
        :experience,
        :level,
        :points,
        :hp,
        :ep,
        :sp
      ],
      :methods => [
        :formatted_basic_money,
        :formatted_vip_money,
        :next_level_experience,
        :level_progress_percentage,
        :health_points,
        :energy_points,
        :stamina_points,
        :time_to_hp_restore,
        :time_to_ep_restore,
        :time_to_sp_restore,
      ]
    )
  end

  def possible_victims(scope_options = {})
    scope = Character.scoped(scope_options)

    # Exclude recent opponents, friends, and self
    exclude_ids = latest_opponent_ids
    exclude_ids.push(*friend_relations.character_ids) unless Setting.b(:fight_alliance_attack)
    exclude_ids.push(id)

    scope = scope.scoped(
      :conditions => ["characters.id NOT IN (?)", exclude_ids]
    )

    # Scope by level
    scope = scope.scoped(
      :conditions => ["level BETWEEN ? AND ?", lowest_opponent_level, highest_opponent_level]
    )

    scope.all(
      :include  => :user,
      :order    => "ABS(level - #{level}), RAND()",
      :limit    => Setting.i(:fight_victim_show_limit)
    ).tap do |result|
      result.shuffle!
    end
  end

  def latest_opponent_ids
    attacks.all(
      :select     => "DISTINCT victim_id",
      :conditions => ["winner_id = ? AND created_at > ?",
        self.id,
        Setting.i(:fight_attack_repeat_delay).minutes.ago
      ]
    ).collect{|a| a.victim_id }
  end

  def lowest_opponent_level
    level - Setting.i(:fight_victim_levels_lower)
  end

  def highest_opponent_level
    level + Setting.i(:fight_victim_levels_higher)
  end

  def can_attack?(victim)
    level_fits        = (lowest_opponent_level..highest_opponent_level).include?(victim.level)
    attacked_recently = latest_opponent_ids.include?(victim.id)
    friendly_attack   = Setting.b(:fight_alliance_attack) ? false : friend_relations.character_ids.include?(victim.id)

    level_fits && !attacked_recently && !friendly_attack
  end

  def can_hitlist?(victim)
    friendly_attack = Setting.b(:fight_alliance_attack) ? false : friend_relations.established?(victim)

    Setting.b(:hit_list_enabled) && !friendly_attack
  end

  def full_energy?
    ep == energy_points
  end

  def full_health?
    hp == health_points
  end

  def full_stamina?
    sp == stamina_points
  end


  def allow_fight_with_invite?
    Setting.b(:fight_with_invite_allowed) and
      level <= Setting.i(:fight_with_invite_max_level)
  end

  def secret(length = 6)
    [0, length]
  end

  def invitation_key
    digest = Digest::MD5.hexdigest("%s-%s" % [created_at, id])

    "%s-%s" % [id, digest[0, 10]]
  end

  def key
    digest = Digest::MD5.hexdigest("%s-%s" % [id, created_at])

    "%s-%s" % [id, digest[0, 10]]
  end

  def charge(basic_amount, vip_amount, reference = nil)
    self.basic_money  -= basic_amount if basic_amount != 0

    if vip_amount.to_i != 0
      deposit = (vip_amount > 0 ? vip_money_withdrawals : vip_money_deposits).build(
        :amount     => vip_amount.abs,
        :reference  => reference
      )
      deposit.character = self
      deposit
    end
  end

  def charge!(*args)
    charge(*args)

    save!
  end

  def equipment
    @equipment ||= Character::Equipment.new(self)
  end

  def boosts
    @boosts ||= Character::Boosts.new(self)
  end

  def placements
    self[:placements] ||= {}
  end

  def health_restore_period
    Setting.i(:character_health_restore_period).seconds
  end

  def energy_restore_period
    Setting.i(:character_energy_restore_period).seconds
  end

  def stamina_restore_period
    Setting.i(:character_stamina_restore_period).seconds
  end

  protected

  def update_level_and_points
    if experience_to_next_level <= 0
      self.level      += 1

      self.points     += Setting.i(:character_points_per_upgrade)

      charge(0, - vip_money_per_upgrade, :level_up)

      self.ep = energy_points
      self.hp = health_points
      self.sp = stamina_points

      notifications.schedule(:level_up)
    end
  end

  def vip_money_per_upgrade
    (Setting.i(:character_vip_money_per_upgrade) + level * Setting.f(:character_vip_money_per_upgrade_per_level)).round
  end

  def apply_character_type_defaults
    CharacterType::APPLICABLE_ATTRIBUTES.each do |attribute|
      send("#{attribute}=", character_type.send(attribute)) if send(attribute).nil?
    end

    self.hp = health_points
    self.ep = energy_points
    self.sp = stamina_points
  end

  def update_total_money
    self.total_money = basic_money + bank
  end
end
