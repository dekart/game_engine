class Fight < ActiveRecord::Base
  OPPONENT_LEVEL_RANGES = [
    1 .. 1,
    2 .. 2,
    3 .. 3,
    4 .. 4,
    5 .. 5,
    6 .. 10,
    11 .. 15,
    16 .. 25,
    26 .. 50,
    51 .. 100,
    101 .. 150,
    151 .. Character::Levels::EXPERIENCE.size
  ]

  belongs_to :attacker, :class_name => "Character"
  belongs_to :victim, :class_name => "Character"
  belongs_to :winner, :class_name => "Character"

  belongs_to  :cause, :polymorphic => true

  scope :with_participant, Proc.new {|character|
    {
      :conditions => ["attacker_id = :id OR victim_id = :id", {:id => character.id}],
      :order => "created_at DESC",
      :include => [:attacker, :victim]
    }
  }

  validate :fight_availability

  before_create :calculate_fight
  after_create  :save_payout, :post_to_newsfeed
  after_create :calculate_victories, :if => :attacker_won?

  attr_reader :attacker_boost, :victim_boost, :payouts

  include Fight::DamageCalculator::Proportion
  include Fight::ResultCalculator::Proportion

  class << self
    def can_attack?(attacker, victim)
      new(:attacker => attacker, :victim => victim).can_attack?
    end

    def level_range(character)
      OPPONENT_LEVEL_RANGES.detect{|r| r.include?(character.level) }
    end
  end

  def attacker_level_range
    self.class.level_range(attacker)
  end

  def can_attack?
    return false if attacker.exclude_from_fights? || victim.exclude_from_fights?
    return false unless attacker_level_range.include?(victim.level)   # Checking level range match
    return false if !Setting.b(:fight_weak_opponents) && victim.weak? # Checking if opponent is too weak
    return false if latest_opponent_ids.include?(victim.id)           # Checking if opponent was attacked recently
    return false if !Setting.b(:fight_alliance_attack) && attacker.friend_relations.character_ids.include?(victim.id) # Checking if opponent is in alliance

    true
  end

  def opponents
    # Exclude recent opponents, friends, and self
    exclude_ids = latest_opponent_ids
    exclude_ids.push(*attacker.friend_relations.character_ids) unless Setting.b(:fight_alliance_attack)
    exclude_ids.push(attacker.id)
    exclude_ids.uniq!

    opponent_ids = Fight::OpponentBuckets.random_opponents(attacker_level_range, exclude_ids, Setting.i(:fight_victim_show_limit))

    Character.all(:include => :user, :conditions => {:id => opponent_ids}).tap do |r|
      r.shuffle!
    end
  end

  def attacker_won?
    @attacker_won ||= winner ? (winner == attacker) : calculate_attacker_victory
  end

  def victim_won?
    !attacker_won?
  end

  def loser
    return nil unless winner

    (self.winner == attacker) ? victim : attacker
  end

  def is_response?
    not cause.nil?
  end

  def response
    self.class.first(:conditions => ["cause_id = ? AND cause_type = 'Fight'", id])
  end

  def responded?
    not response.nil?
  end

  def respondable?
    attacker_won? and not responded?
  end

  def enough_stamina?
    attacker.sp >= Setting.i(:fight_stamina_required)
  end

  def stamina_requirement
    Requirements::StaminaPoint.new(:value => Setting.i(:fight_stamina_required))
  end

  def attacker_used_items
    used_items(attacker)
  end

  def victim_used_items
    used_items(victim)
  end

  def used_items(character)
    items = character.inventories.equipped

    groups = ItemGroup.with_state(:visible).all(:order => :position)

    ActiveSupport::OrderedHash.new.tap do |result|
      groups.each do |group|
        items_by_group = items.select{|i| i.item_group_id == group.id }

        result[group] = items_by_group if items_by_group.any?
      end
    end
  end

  protected

  def fight_availability
    if !enough_stamina?
      errors.add(:attacker, :not_enough_stamina)
    elsif attacker.weak?
      errors.add(:attacker, :too_weak)
    elsif !Setting.b(:fight_weak_opponents) && victim.weak? && !cause.is_a?(HitListing)
      errors.add(:victim, :too_weak)
    elsif !Setting.b(:fight_alliance_attack) && attacker.friend_relations.established?(victim)
      errors.add(:attacker, :cannot_attack_friends)
    elsif (is_response? && cause.is_a?(Fight) && !cause.respondable?) || (!is_response? && !can_attack?)
      errors.add(:attacker, :cannot_attack)
    elsif attacker == victim
      errors.add(:attacker, :cannot_attack_self)
    end
  end

  def calculate_fight
    self.winner = attacker_won? ? attacker : victim

    victim_damage, attacker_damage = calculate_damage

    self.victim_hp_loss = victim_damage
    self.attacker_hp_loss = attacker_damage

    self.experience = Setting.p(:fight_experience, rand(loser.level)).ceil
    self.experience = 1 if experience == 0

    self.winner_money = winner_reward
    self.loser_money  = (loser.basic_money >= winner_money ? winner_money : loser.basic_money)

    @attacker_boost = attacker.boosts.active_for(:fight, :attack)
    @victim_boost   = victim.boosts.active_for(:fight, :defence)
  end

  def winner_reward
    if loser.basic_money > 0
      fight_money_bonus = 0.01 * winner.assignments.fight_income_effect

      [
        (rand(loser.basic_money) * (Setting.i(:fight_money_loot) * 0.01 + fight_money_bonus)).ceil,
        Setting.i(:fight_max_money)
      ].min
    else
      (Setting.i(:fight_min_money) + Setting.f(:fight_min_money_per_level) * loser.level).round
    end
  end

  def save_payout
    winner.experience += experience

    winner.charge(- winner_money, 0, :fight_win)
    loser.charge(loser_money, 0, :fight_lose)

    attacker.sp  -= Setting.i(:fight_stamina_required)

    attacker.hp  -= attacker_hp_loss

    victim.hp    -= victim_hp_loss if decrease_victim_health?

    attacker.inventories.take!(@attacker_boost.item) if @attacker_boost
    victim.inventories.take!(@victim_boost.item) if @victim_boost

    if global_payout = GlobalPayout.by_alias(:fights)
      @payouts = global_payout.payouts.apply(attacker, attacker == winner ? :success : :failure)
    end

    # update statistics only for current character
    if attacker == winner
      attacker.fights_won += 1
    else
      attacker.fights_lost += 1
    end

    attacker.save!
    victim.save!
  end

  def calculate_victories
    $redis.zadd("fight_victories_#{attacker.id}", Time.now.to_i, victim.id)

    true
  end

  def post_to_newsfeed
    attacker.news.add(:fight_result, :fight_id => id)
    victim.news.add(:fight_result, :fight_id => id)
  end

  def latest_opponent_ids
    $redis.zremrangebyscore("fight_victories_#{attacker.id}", 0, Setting.i(:fight_attack_repeat_delay).minutes.ago.to_i)

    $redis.zrange("fight_victories_#{attacker.id}", 0, -1).collect {|id| id.to_i }
  end

  def decrease_victim_health?
    cause || (victim.user.last_visit_at && victim.user.last_visit_at > Setting.i(:fight_victim_hp_decrease_if_character_was_online).hours.ago)
  end
end
