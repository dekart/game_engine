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
  after_create  :save_payout, :update_victim_dashboard, :post_to_newsfeed

  cattr_accessor :fighting_system, :damage_system
  @@fighting_system = FightingSystem::PlayerVsPlayer::Proportion
  @@damage_system = FightingSystem::DamageCalculation::Proportion

  attr_reader :attacker_boost, :victim_boost

  def attacker_won?
    self.winner == attacker
  end

  def victim_won?
    self.winner == victim
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

  protected

  def validate
    errors.add(:character, :not_enough_stamina) unless enough_stamina?

    if !Setting.b(:fight_alliance_attack) && attacker.friend_relations.established?(victim)
      errors.add(:character, :cannot_attack_friends)
    end

    if (is_response? and cause.is_a?(Fight) and !cause.respondable?) or
       (!is_response? and !attacker.can_attack?(victim)) or
       (attacker == victim)
      errors.add(:character, :cannot_attack)
    end

    if attacker.weak?
      errors.add(:character, :too_weak)
    end
  end

  def calculate_fight
    won = self.class.fighting_system.calculate(attacker, victim)

    victim_damage, attacker_damage = self.class.damage_system.calculate(attacker, victim, won)

    self.winner = won ? attacker : victim

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
    victim.hp    -= victim_hp_loss

    attacker.inventories.take!(@attacker_boost.item) if @attacker_boost
    victim.inventories.take!(@victim_boost.item) if @victim_boost

    winner.fights_won += 1
    loser.fights_lost += 1

    attacker.save!
    victim.save!
  end

  def update_victim_dashboard
    Delayed::Job.enqueue Jobs::FightNotification.new(id)
  end

  def post_to_newsfeed
    attacker.news.add(:fight_result, :fight_id => id)
    victim.news.add(:fight_result, :fight_id => id)
  end
end
