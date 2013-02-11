class Character < ActiveRecord::Base
  extend SerializeWithPreload
  extend RestorableAttribute
  extend HasPayouts
  include ActionView::Helpers::NumberHelper

  include Character::Levels
  include Character::Fights
  include Character::AppRequests
  include Character::Relations
  include Character::Assignments
  include Character::Properties
  include Character::Notifications
  include Character::Collections
  include Character::Newsfeed
  include Character::Hospital
  include Character::Monsters
  include Character::Premium
  include Character::SecretKeys
  include Character::Contests
  include Character::PersonalDiscounts
  include Character::Ratings
  include Character::Exchanges
  include Character::Achievements
  include Character::Clans
  include Character::Complaints
  include Character::Messages

  UPGRADABLE_ATTRIBUTES = [:attack, :defence, :health, :energy, :stamina]

  belongs_to :user

  has_many :ordered_hit_listings,
    :foreign_key  => :client_id,
    :class_name   => "HitListing",
    :dependent    => :destroy

  has_many :bank_deposits,
    :dependent => :delete_all
  has_many :bank_withdrawals,
    :class_name => "BankWithdraw",
    :dependent  => :delete_all

  has_many :vip_money_deposits,
    :dependent => :destroy
  has_many :vip_money_withdrawals,
    :dependent => :destroy

  has_many :market_items

  has_many :wall_posts,
    :dependent => :destroy

  has_one :mission_state
  has_one :inventory_state

  scope :by_profile_ids, Proc.new{|ids|
    user_ids = User.where(:facebook_id => ids).pluck(:id)

    {
      :joins => :user,
      :conditions => ["characters.id IN (?) OR characters.user_id IN (?)", ids, user_ids]
    }
  }

  serialize :active_boosts

  attr_accessible :name, :exclude_from_fights, :restrict_fighting, :restrict_market, :restrict_talking

  has_payouts :save

  restorable_attribute :hp,
    :limit          => :health_points,
    :restore_period => 45.seconds,
    :restore_bonus  => :health_restore_bonus
  restorable_attribute :ep,
    :limit          => :energy_points,
    :restore_period => 45.seconds,
    :restore_bonus  => :energy_restore_bonus
  restorable_attribute :sp,
    :limit          => :stamina_points,
    :restore_period => 45.seconds,
    :restore_bonus  => :stamina_restore_bonus

  after_validation :apply_character_type_defaults, :on => :create
  before_save :update_level_and_points, :unless => :level_up_applied
  before_save :update_total_money
  after_save :update_current_contest_points

  validates_presence_of :character_type, :on => :create

  delegate(:facebook_id, :to => :user)

  attr_accessor :level_up_applied

  class << self
    def banned_ids
      Rails.cache.fetch('character_banned_ids', :expires_in => 15.minutes) do
        [0] + Character.all(:select => "characters.id", :joins => :user, :conditions => 'banned IS TRUE').map{|c| c.id }
      end
    end
  end

  def character_type
    GameData::CharacterType[character_type_id]
  end

  def character_type=(value)
    self.character_type_id = value.is_a?(GameData::CharacterType) ? value.id : GameData::CharacterType[value].id
  end

  def missions
    (mission_state || create_mission_state).tap do |s|
      s.character = self
    end
  end

  def inventory
    (inventory_state || create_inventory_state).tap do |s|
      s.character = self
    end
  end

  # def buy_item!(key, amount = 1)
  #   item = GameData::Item[key]

  #   basic_price = item.basic_price * amount
  #   vip_price = item.vip_price * amount

  #   errors = []
  #   errors.push(:not_enough_basic_money) if basic_money < basic_price
  #   errors.push(:not_enough_vip_money)   if vip_money < vip_price

  #   return errors unless errors.empty?

  #   effective_amount = amount * item.package_size

  #   ActiveSupport::Notifications.instrument(:buy_item,
  #     :item         => item,
  #     :basic_money  => basic_price,
  #     :vip_money    => vip_price
  #   )

  #   transaction do
  #     inventory.give(item, effective_amount)
  #     charge(basic_price, vip_price, item)

  #     if save
  #       item.increment_owned(effective_amount)

  #       inventory.equip!(item)

  #       character.news.add(:item_purchase, :item_id => item.id, :amount => effective_amount)

  #       check_item_collections(item)
  #     end
  #   end
  # end

  def nickname(friend = false)
    friend = friend.user.friends_with?(self) if friend.is_a?(Character)

    if friend
      if name.present?
        I18n.t('characters.real_name_with_nickname',
          :first_name => user.first_name,
          :last_name  => user.last_name,
          :nickname   => name
        )
      else
        I18n.t('characters.real_name',
          :first_name => user.first_name,
          :last_name  => user.last_name
        )
      end
    elsif name.present?
      name
    else
      user.first_name
    end
  end

  def basic_money=(value)
    self[:basic_money] = [value.to_i, 0].max
  end

  def vip_money=(value)
    self[:vip_money] = [value.to_i, 0].max
  end

  def self_and_relations
    self.class.where(:id => [id] + friend_relations.character_ids)
  end

  def upgrade_attributes!(params)
    sum_points = 0

    UPGRADABLE_ATTRIBUTES.each do |attribute|
      sum_points += Setting.i("character_#{attribute}_upgrade_points") * params[attribute].to_i.abs
    end

    return false if points < sum_points

    transaction do
      UPGRADABLE_ATTRIBUTES.each do |attribute|
        upgrade_by = params[attribute].to_i.abs

        case attribute
        when :health
          self.health += Setting.i(:character_health_upgrade) * params[:health].to_i.abs
          self.hp     += Setting.i(:character_health_upgrade) * params[:health].to_i.abs
        when :energy
          self.energy += Setting.i(:character_energy_upgrade) * params[:energy].to_i.abs
          self.ep     += Setting.i(:character_energy_upgrade) * params[:energy].to_i.abs
        when :stamina
          self.stamina  += Setting.i(:character_stamina_upgrade) * params[:stamina].to_i.abs
          self.sp       += Setting.i(:character_stamina_upgrade) * params[:stamina].to_i.abs
        else
          increment(attribute, Setting.i("character_#{attribute}_upgrade") * upgrade_by)
        end

        self.points -= Setting.i("character_#{attribute}_upgrade_points") * upgrade_by
      end

      save
    end
  end

  def attack_points
    attack +
      character_type.attributes[:attack] +
      inventory.effects[:attack] +
      assignments.attack_effect +
      boosts.active_for(:fight, :attack).try(:effect, :attack).to_i
  end

  def defence_points
    defence +
      character_type.attributes[:defence] +
      inventory.effects[:defence] +
      assignments.defence_effect +
      boosts.active_for(:fight, :defence).try(:effect, :defence).to_i
  end

  def health_points
    health +
      character_type.attributes[:health] +
      inventory.effects[:health]
  end

  def energy_points
    energy +
      character_type.attributes[:energy] +
      inventory.effects[:energy]
  end

  def stamina_points
    stamina +
      character_type.attributes[:stamina] +
      inventory.effects[:stamina]
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
    if Setting.s(:character_weakness_minimum_formula) == 'percentage'
      Setting.p(:character_weakness_minimum, health_points)
    else
      Setting.i(:character_weakness_minimum)
    end
  end

  def to_json_for_overview
    as_json_for_overview.to_json
  end

  def as_json_for_overview
    as_json(
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
        :next_level_experience,
        :level_progress_percentage,
        :health_points,
        :energy_points,
        :stamina_points,
        :time_to_hp_restore,
        :time_to_ep_restore,
        :time_to_sp_restore,
        :notifications_count,
        :facebook_id
      ]
    )
  end

  def as_json_for_upgrade
    {
      :points   => points,
      :upgrade_cost => {},
      :upgrade_increase => {}
    }.tap do |result|
      UPGRADABLE_ATTRIBUTES.each do |attribute|
        result[attribute] = send(attribute)
        result[:upgrade_cost][attribute] = Setting.i("character_#{attribute}_upgrade_points")
        result[:upgrade_increase][attribute] = Setting.i("character_#{attribute}_upgrade")
      end
    end.as_json
  end

  def as_json_for(character)
    {
      :key => key,
      :nickname => nickname(character),
      :user => user.as_json_for(character.user)
    }
  end

  def show_promo_block?
    level >= Setting.i(:promo_block_minimum_level)
  end

  def can_hitlist?(victim)
    friendly_attack = Setting.b(:fight_alliance_attack) ? false : friend_relations.established?(victim)

    Setting.b(:hit_list_enabled) && !friendly_attack && !victim.exclude_from_fights?
  end

  def allow_fight_with_invite?
    Setting.b(:fight_with_invite_allowed) and
      level <= Setting.i(:fight_with_invite_max_level)
  end

  def charge(basic_amount, vip_amount, reference = nil)
    self.basic_money  -= basic_amount.to_i

    if vip_amount.to_i != 0
      target = (vip_amount.to_i > 0 ? vip_money_withdrawals : vip_money_deposits)

      target.build(
        :amount     => vip_amount.abs,
        :reference  => reference
      ).tap do |o|
        o.character = self
        o.save!
      end
    end
  end

  def charge!(*args)
    transaction do
      charge(*args)

      save!
    end
  end

  def market_items_count(item)
    market_items.where(:item_id => item).count
  end

  def boosts
    @boosts ||= Character::Boosts.new(self)
  end

  def active_boosts
    self[:active_boosts] ||= {}
  end

  def active_boost?(boost, destination)
    active_boosts[boost.boost_type] && active_boosts[boost.boost_type][destination] == boost.id
  end

  def activate_boost(boost, destination)
    active_boosts[boost.boost_type] ||= {}
    active_boosts[boost.boost_type][destination] = boost.id
  end

  def activate_boost!(boost, destination)
    activate_boost(boost, destination)
    save!
  end

  def deactivate_boost(boost, destination)
    active_boosts[boost.boost_type].delete(destination) if active_boosts[boost.boost_type] &&
      active_boosts[boost.boost_type][destination] == boost.id
  end

  def deactivate_boost!(boost, destination)
    deactivate_boost(boost, destination)
    save!
  end

  def toggle_boost(boost, destination)
    if active_boosts[boost.boost_type] && active_boosts[boost.boost_type][destination] == boost.id
      deactivate_boost(boost, destination)
    else
      activate_boost(boost, destination)
    end
  end

  def toggle_boost!(boost, destination)
    toggle_boost(boost, destination)
    save!
  end

  def health_restore_bonus
    character_type.attributes[:hp_restore_rate] + inventory.effects[:hp_restore_rate]
  end

  def energy_restore_bonus
    character_type.attributes[:ep_restore_rate] + inventory.effects[:ep_restore_rate]
  end

  def stamina_restore_bonus
    character_type.attributes[:sp_restore_rate] + inventory.effects[:sp_restore_rate]
  end

  def friend_filter
    @friend_filter ||= FriendFilter.new(self)
  end

  def event_data
    {
      :character_id => self.id,
      :level => self.level
    }
  end

  def notifications_count
    self.notifications.count
  end

  protected

  def update_level_and_points
    self.level = [level, level_for_current_experience].max

    if level_changed?
      self.level_up_applied = true

      self.points += level_up_amount * Setting.i(:character_points_per_upgrade)

      charge!(0, - vip_money_per_upgrade, :level_up)

      refill_ep!
      refill_hp!
      refill_sp!

      notifications.schedule(:level_up)

      update_opponent_bucket # Update character position in opponent buckets
    end

    true
  end

  def level_up_amount
    level_change[1] - level_change[0]
  end

  def vip_money_per_upgrade
    (Setting.i(:character_vip_money_per_upgrade) * level_up_amount + level * Setting.f(:character_vip_money_per_upgrade_per_level)).round
  end

  def apply_character_type_defaults
    character_type.apply_reward_on(:create, self)
  end

  def update_total_money
    self.total_money = basic_money + bank
  end

  def update_current_contest_points
    if contest = Contest.current and try("#{ contest.points_type }_changed?")
      old, now = send("#{ contest.points_type }_change")

      contest.increment_points!(self, now - old)
    end
  end
end
