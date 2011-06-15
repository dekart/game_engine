class Fight < ActiveRecord::Base
  belongs_to :attacker, :class_name => "Character", :extend => Fight::UsedItems
  belongs_to :victim, :class_name => "Character", :extend => Fight::UsedItems
  belongs_to :winner, :class_name => "Character"

  belongs_to  :cause, :polymorphic => true

  named_scope :with_participant, Proc.new {|character|
    {
      :conditions => ["attacker_id = :id OR victim_id = :id", {:id => character.id}],
      :order => "created_at DESC",
      :include => [:attacker, :victim]
    }
  }

  before_create :calculate_fight
  after_create  :save_payout, :post_to_newsfeed, :log_event

  attr_reader :attacker_boost, :victim_boost, :payouts
  
  include Fight::DamageCalculator::Proportion
  include Fight::OpponentSelector::Simple
  include Fight::ResultCalculator::Proportion
  
  class << self
    def can_attack?(attacker, victim)
      new(:attacker => attacker, :victim => victim).can_attack?
    end
  end
  
  def can_attack?
    attacked_recently = latest_opponent_ids.include?(victim.id)
    friendly_attack   = Setting.b(:fight_alliance_attack) ? false : attacker.friend_relations.character_ids.include?(victim.id)
    weak_opponent     = Setting.b(:fight_weak_opponents) ? false : victim.weak?

    super && !attacked_recently && !friendly_attack && !weak_opponent
  end
  
  def opponents
    scope = super
    
    # Exclude recent opponents, friends, and self
    exclude_ids = latest_opponent_ids
    exclude_ids.push(*attacker.friend_relations.character_ids) unless Setting.b(:fight_alliance_attack)
    exclude_ids.push(attacker.id)

    scope = scope.scoped(
      :include    => :user,
      :conditions => ["characters.id NOT IN (?)", exclude_ids],
      :limit      => Setting.i(:fight_victim_show_limit)
    )

    unless Setting.b(:fight_weak_opponents)
      scope = scope.scoped(
        :conditions => ["fighting_available_at < ?", Time.now.utc]
      )
    end
    
    scope.all(
      :order => "ABS(level - #{ attacker.level }) ASC, RAND()"
    ).tap do |result|
      result.shuffle!
    end
  end
    
  def attacker_won?
    if @attacker_won.nil?
      @attacker_won = calculate_attacker_victory
    else
      @attacker_won
    end
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

  def attacker_event_data
    {
      :reference_id => self.victim.id,
      :reference_type => "Character",
      :reference_level => self.victim.level,
      :reference_damage => -self.victim_hp_loss,
      :health => -self.attacker_hp_loss,
      :basic_money => self.attacker_won? ? self.winner_money : -self.loser_money,
      :experience => self.experience
    }
  end
  
  def victim_event_data
    {
      :reference_id => self.attacker.id,
      :reference_type => "Character",
      :reference_level => self.attacker.level,
      :reference_damage => -self.attacker_hp_loss,
      :health => -self.victim_hp_loss,
      :basic_money => self.attacker_won? ? -self.loser_money : self.winner_money,
      :experience => 0
    }
  end

  protected

  def validate
    if !enough_stamina?
      errors.add(:character, :not_enough_stamina)
    elsif attacker.weak?
      errors.add(:character, :too_weak)
    elsif !Setting.b(:fight_weak_opponents) && victim.weak?
      errors.add(:victim, :too_weak)
    elsif !Setting.b(:fight_alliance_attack) && attacker.friend_relations.established?(victim)
      errors.add(:character, :cannot_attack_friends)
    elsif (is_response? && cause.is_a?(Fight) && !cause.respondable?) || (!is_response? && !can_attack?)
      errors.add(:character, :cannot_attack)
    elsif attacker == victim
      errors.add(:character, :cannot_attack_self)
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

    @attacker_boost = attacker.boosts.best_attacking
    @victim_boost = victim.boosts.best_defending
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
      
      if contest = Contest.current.first and contest.started?
        contest.inc_points!(attacker)
      end
    else
      attacker.fights_lost += 1
    end

    attacker.save!
    victim.save!
  end

  def post_to_newsfeed
    attacker.news.add(:fight_result, :fight_id => id)
    victim.news.add(:fight_result, :fight_id => id)
  end
  
  def log_event
    EventLoggingService.log_event(:character_attacked, self)
    EventLoggingService.log_event(:character_under_attack, self)
  end
  
  def latest_opponent_ids
    attacker.attacks.all(
      :select     => "DISTINCT victim_id",
      :conditions => ["winner_id = ? AND created_at > ?", attacker.id, Setting.i(:fight_attack_repeat_delay).minutes.ago]
    ).collect{|a| a.victim_id }
  end
  
  def decrease_victim_health?
    victim.user.last_visit_at && victim.user.last_visit_at > Setting.i(:fight_victim_hp_decrease_if_character_was_online).hours.ago 
  end
end
