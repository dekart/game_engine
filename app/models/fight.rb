class Fight < ActiveRecord::Base
  belongs_to :attacker, :class_name => "Character"
  belongs_to :victim, :class_name => "Character"
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
  after_create  :save_payout, :update_victim_dashboard

  cattr_accessor :fighting_system
  @@fighting_system = FightingSystem::PlayerVsPlayer::Proportion

  def attacker_won?
    self.winner == self.attacker
  end

  def victim_won?
    self.winner == self.victim
  end

  def loser
    return nil if self.winner.nil?

    return self.winner == self.attacker ? self.victim : self.attacker
  end

  def is_response?
    not cause.nil?
  end

  def response
    self.class.first(:conditions => ["cause_id = ? AND cause_type = 'Fight'", self.id])
  end

  def responded?
    not response.nil?
  end

  def respondable?
    attacker_won? and not responded?
  end

  protected

  def validate
    if self.attacker.sp < Setting.i(:fight_stamina_required)
      self.errors.add(:character, :not_enough_stamina)
    end

    if (is_response? and cause.is_a?(Fight) and !cause.respondable?) or (!is_response? and Character.victims_for(self.attacker).find_by_id(self.victim.id).nil?) or (attacker == victim)
      self.errors.add(:character, :cannot_attack)
    end

    if self.attacker.weak?
      self.errors.add(:character, :too_weak)
    end
  end

  def calculate_fight
    won, victim_damage, attacker_damage = self.class.fighting_system.calculate(attacker, victim)

    self.winner = won ? attacker : victim

    self.victim_hp_loss = victim_damage
    self.attacker_hp_loss = attacker_damage

    self.experience = Setting.p(:fight_experience, rand(loser.level)).ceil
    self.experience = 1 if experience == 0

    if loser.basic_money == 0
      self.money = 0
    else
      fight_money_bonus = 0.01 * winner.assignments.effect_value(:fight_income)

      self.money = [
        (rand(loser.basic_money) * (Setting.i(:fight_money_loot) * 0.01 + fight_money_bonus)).ceil,
        Setting.i(:fight_max_money)
      ].min
    end
  end

  def save_payout
    self.winner.experience += self.experience

    self.winner.basic_money += self.money
    self.loser.basic_money  -= self.money

    self.attacker.sp  -= Setting.i(:fight_stamina_required)

    self.attacker.hp  -= self.attacker_hp_loss
    self.victim.hp    -= self.victim_hp_loss

    self.winner.fights_won += 1
    self.loser.fights_lost += 1

    self.attacker.save!
    self.victim.save!
  end

  def update_victim_dashboard
    Delayed::Job.enqueue Jobs::FightNotification.new(self.id)
  end
end
