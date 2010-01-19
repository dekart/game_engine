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
  after_create  :save_payout

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
    if self.attacker.ep < Configuration[:fight_energy_required]
      self.errors.add(:character, :not_enough_energy)
    end

    if (is_response? and cause.is_a?(Fight) and !cause.respondable?) or (!is_response? and Character.victims_for(self.attacker).find_by_id(self.victim.id).nil?) or (attacker == victim)
      self.errors.add(:character, :cannot_attack)
    end

    if self.attacker.weak?
      self.errors.add(:character, :too_weak)
    end
  end

  def calculate_fight
    attacker_won, self.victim_hp_loss, self.attacker_hp_loss = calculate_proportions(self.attacker, self.victim)

    self.winner = attacker_won ? self.attacker : self.victim

    self.experience = (rand(self.loser.level) * Configuration[:fight_experience] * 0.01).ceil
    self.experience = 1 if self.experience == 0

    if self.loser.basic_money == 0
      self.money = 0
    else
      fignt_money_bonus = 0.01 * self.winner.assignments.effect_value(:fight_income)

      self.money = [
        (rand(self.loser.basic_money) * (Configuration[:fight_money_loot] * 0.01 + fignt_money_bonus)).ceil,
        Configuration[:fight_max_money]
      ].min
    end
  end

  def save_payout
    self.winner.experience += self.experience

    self.winner.basic_money += self.money
    self.loser.basic_money  -= self.money

    self.attacker.ep  -= Configuration[:fight_energy_required]

    self.attacker.hp  -= self.attacker_hp_loss
    self.victim.hp    -= self.victim_hp_loss

    self.winner.fights_won += 1
    self.loser.fights_lost += 1

    self.attacker.save!
    self.victim.save!
  end

  def calculate_proportions(attacker, victim)
    attack_points = attacker.attack_points
    defence_points = victim.defence_points
    attack_bonus = 1.0
    defence_bonus = 1.0

    attack = attack_points * attack_bonus * 50
    defence = defence_points * defence_bonus * 50

    attacker_won = (rand((attack + defence).to_i) >= defence)

    if attacker_won
      victim_damage_reduce    = 0.01 * victim.assignments.effect_value(:fight_damage)

      attack_damage   = rand(victim.health * 1000) * (1 - victim_damage_reduce) * Configuration[:fight_max_loser_damage] * 0.01
      defence_damage  = rand(attack_damage * (attack > defence ? defence / attack : Configuration[:fight_max_winner_damage] * 0.01))
    else
      attacker_damage_reduce  = 0.01 * attacker.assignments.effect_value(:fight_damage)

      defence_damage  = rand(attacker.health * 1000) * Configuration[:fight_max_loser_damage] * 0.01 * (1 - attacker_damage_reduce)
      attack_damage   = rand(defence_damage * (defence > attack ? attack / defence : Configuration[:fight_max_winner_damage] * 0.01))
    end

    return [attacker_won, (attack_damage / 1000).ceil, (defence_damage / 1000).ceil]
  end
end
