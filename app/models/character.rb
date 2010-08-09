class Character < ActiveRecord::Base
  extend SerializeWithPreload
  extend RestorableAttribute
  extend HasPayouts
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
    :foreign_key  => "owner_id",
    :order        => "type",
    :extend       => Character::Relations
  has_many :friend_relations, 
    :foreign_key  => "owner_id",
    :include      => :character,
    :dependent    => :destroy,
    :extend       => Character::FriendRelations
  has_many :reverse_friend_relations, 
    :foreign_key  => "character_id",
    :class_name   => "FriendRelation",
    :dependent    => :destroy
  has_many :mercenary_relations, 
    :foreign_key  => "owner_id",
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
  has_many :gift_receipts, :through => :gifts, :source => :receipts, :extend => Character::GiftReceipts

  has_many :boss_fights,
    :extend => Character::BossFights

  has_many :ordered_hit_listings, :foreign_key => :client_id, :class_name => "HitListing"

  has_many :bank_deposits
  has_many :bank_withdrawals, :class_name => "BankWithdraw"

  has_many :vip_money_deposits
  has_many :vip_money_withdrawals

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

  named_scope :not_friends_with, Proc.new{|character|
    ids = character.friend_relations.character_ids
    
    ids.any? ? {:conditions => ["characters.id NOT IN (?)", ids]} : {}
  }

  serialize :placements

  attr_accessible :name

  attr_accessor :level_updated

  has_payouts :save

  restorable_attribute :hp,
    :limit          => :health_points,
    :restore_period => Setting.i(:character_health_restore_period).seconds,
    :restore_bonus  => :health_restore_bonus
  restorable_attribute :ep, 
    :limit          => :energy_points,
    :restore_period => Setting.i(:character_energy_restore_period).seconds,
    :restore_bonus  => :energy_restore_bonus
  restorable_attribute :sp,
    :limit          => :stamina_points,
    :restore_period => Setting.i(:character_stamina_restore_period).seconds,
    :restore_bonus  => :stamina_restore_bonus

  after_validation_on_create :apply_character_type_defaults
  before_save   :update_level_and_points, :apply_payouts, :update_total_money

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
      count(:conditions => ["#{field} > ?", character.send(field)]) + 1
    end

    def level_for_experience(value)
      LEVELS.each_with_index do |experience, level|
        return level if experience >= value
      end
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
    attack + inventories.effect(:attack) + assignments.effect_value(:attack)
  end

  def defence_points
    defence + inventories.effect(:defence) + assignments.effect_value(:defence)
  end

  def health_points
    health + inventories.effect(:health)
  end

  def energy_points
    energy + inventories.effect(:energy)
  end

  def stamina_points
    stamina + inventories.effect(:stamina)
  end

  def fight_damage_reduce
    assignments.effect_value(:fight_damage)
  end

  def weak?
    hp < weakness_minimum
  end

  def weakness_minimum
    Setting.p(:character_weakness_minimum, health).to_i
  end

  def experience_to_next_level
    next_level_experience - experience
  end

  def next_level_experience
    LEVELS[level]
  end

  def level_progress_percentage
    (100 - experience_to_next_level.to_f / (next_level_experience - LEVELS[level - 1]) * 100).round
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

  def can_attack?(victim)
    scope = self.class.victims_for(self)
    scope = scope.not_friends_with(self) unless Setting.b(:fight_alliance_attack)

    scope.find_by_id(victim.id).present?
  end

  def rank_for_mission(mission)
    ranks.find_or_initialize_by_mission_id(mission.id)
  end

  def exchange_money!
    return if vip_money < Setting.i(:premium_money_price)

    charge!(- Setting.i(:premium_money_amount), Setting.i(:premium_money_price), :premium_money)
  end

  def full_energy?
    ep == energy_points
  end

  def refill_energy!(free = false)
    return if full_energy? or (!free and vip_money < Setting.i(:premium_energy_price))

    self.ep = energy_points

    free ? save : charge!(0, Setting.i(:premium_energy_price), :premium_energy)
  end

  def full_health?
    hp == health_points
  end

  def refill_health!(free = false)
    return if full_health? or (!free and vip_money < Setting.i(:premium_health_price))

    self.hp = health_points

    free ? save : charge!(0, Setting.i(:premium_health_price), :premium_health)
  end

  def full_stamina?
    sp == stamina_points
  end

  def refill_stamina!(free = false)
    return if full_stamina? or (!free and vip_money < Setting.i(:premium_stamina_price))

    self.sp = stamina_points

    free ? save : charge!(0, Setting.i(:premium_stamina_price), :premium_stamina)
  end

  def buy_points!
    return if vip_money < Setting.i(:premium_points_price)

    self.points += Setting.i(:premium_points_amount)

    charge!(0, Setting.i(:premium_points_price), :premium_points)
  end

  def hire_mercenary!
    return if vip_money < Setting.i(:premium_mercenary_price)

    transaction do
      mercenary_relations.create!

      charge!(0, Setting.i(:premium_mercenary_price), :premium_mercenary)
    end
  end

  def reset_attributes!
    return if vip_money < Setting.i(:premium_reset_attributes_price)

    free_points = 0

    UPGRADABLE_ATTRIBUTES.each do |attribute|
      current_value = self[attribute]
      new_value     = character_type[attribute]

      free_points += (current_value - new_value) *
        Setting.i("character_#{attribute}_upgrade_points") /
        Setting.i("character_#{attribute}_upgrade")

      self[attribute] = new_value

    end

    self.points += free_points

    self.hp = health_points if hp > health_points
    self.ep = energy_points if ep > energy_points

    charge!(0, Setting.i(:premium_reset_attributes_price), :premium_reset_attributes)
  end

  def change_name!
    return if vip_money < Setting.i(:premium_change_name_price)

    charge!(0, Setting.i(:premium_change_name_price), :premium_change_name)
  end

  def allow_fight_with_invite?
    Setting.b(:fight_with_invite_allowed) and
      level <= Setting.i(:fight_with_invite_max_level)
  end

  def secret(length = 6)
    Digest::MD5.hexdigest("%s-%s" % [id, created_at])[0, length]
  end

  def invitation_key
    "%s-%s" % [id, secret]
  end

  def key
    "%s-%s" % [id, secret(10)]
  end

  def charge(basic_amount, vip_amount, reference = nil)
    self.basic_money  -= basic_amount if basic_amount != 0

    if vip_amount > 0 # charging
      vip_money_withdrawals.build(
        :amount     => vip_amount,
        :reference  => reference
      )
    elsif vip_amount < 0 # depositing
      vip_money_deposits.build(
        :amount     => - vip_amount,
        :reference  => reference
      )
    end
  end

  def charge!(*args)
    charge(*args)
    
    save!
  end

  def titles
    (ranks.completed + mission_group_ranks.completed).collect do |rank|
      rank.title unless rank.title.blank?
    end.compact
  end

  def personalize_from(facebook_session)
    profile_info = facebook_session.users([user.facebook_id], [:name]).first

    self.name = profile_info.name if name.blank?
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

  # TODO Refactor this
  def accept_gifts id
    if id == 'all'
      gift_receipts = GiftReceipt.unaccepted.for_character(self)

      gift_receipts.each(&:give_item_to_character!).map(&:gift).uniq
    else
      gift = Gift.find id
      gift_receipt = gift.receipts.unaccepted.for_character(self).first

      if gift_receipt
        gift_receipt.give_item_to_character!
        [gift]
      else
        []
      end
    end
  end

  def has_unaccepted_gifts?
    ! GiftReceipt.unaccepted.for_character(self).count.zero?
  end

  def hospital_price
    Setting.i(:hospital_price) +
      Setting.i(:hospital_price_per_point_per_level) * level * (health_points - hp)
  end

  def hospital_delay
    value = 
      Setting.i(:hospital_delay) +
      Setting.i(:hospital_delay_per_level) * level

    value.minutes
  end

  def hospital!
    if basic_money < hospital_price
      errors.add_to_base(:hospital_not_enough_money)
      
      return false
    elsif hospital_used_at > hospital_delay.ago
      errors.add_to_base(:hospital_recently_used)
      
      return false
    end

    charge(hospital_price, 0)

    self.hp = health_points
    
    self.hospital_used_at = Time.now

    save
  end

  protected

  def update_level_and_points
    if experience_to_next_level <= 0
      self.level      += 1
      
      self.points     += Setting.i(:character_points_per_upgrade)

      charge(0, - Setting.i(:character_vip_money_per_upgrade), :level_up)

      self.ep = energy_points
      self.hp = health_points
      self.sp = stamina_points

      self.level_updated = true
    end
  end

  def apply_character_type_defaults
    CharacterType::APPLICABLE_ATTRIBUTES.each do |attribute|
      send("#{attribute}=", character_type.send(attribute)) if send(attribute).nil?
    end

    self.hp = health_points
    self.ep = energy_points
    self.sp = stamina_points
  end

  def apply_payouts
    @payouts.apply(self, :save) if @payouts
  end

  def update_total_money
    self.total_money = basic_money + bank
  end
end
