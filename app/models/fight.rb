require "dice"

class Fight < ActiveRecord::Base
  belongs_to :attacker, :class_name => "Character"
  belongs_to :victim, :class_name => "Character"
  belongs_to :winner, :class_name => "Character"

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

  protected

  def validate
    if self.attacker.ep == 0
      self.errors.add(:character, :not_enough_energy)
    end

    if Character.victims_for(self.attacker).find(:first, :conditions => {:id => self.victim.id}).nil?
      self.errors.add(:character, :cannot_attack)
    end

    if self.attacker.weak?
      self.errors.add(:character, :too_weak)
    end
  end

  def calculate_fight
    attacker_won, self.victim_hp_loss, self.attacker_hp_loss = calculate_dices(self.attacker, self.victim)

    self.winner = attacker_won ? self.attacker : self.victim

    self.experience = (rand(self.loser.level) * 0.5).ceil
    self.experience = 1 if self.experience == 0

    if self.loser.basic_money == 0
      self.money = 0
    else
      fignt_money_bonus = 0.01 * self.winner.assignments.effect_value(:fight_income)

      self.money = (rand(self.loser.basic_money) * (0.10 + fignt_money_bonus)).ceil
    end
  end

  def save_payout
    self.winner.increment(:experience, self.experience)

    self.winner.increment(:basic_money, self.money)
    self.loser.decrement(:basic_money, self.money)

    self.attacker.ep  -= 1

    self.attacker.hp  -= self.attacker_hp_loss
    self.victim.hp    -= self.victim_hp_loss

    self.winner.increment(:fights_won)
    self.loser.increment(:fights_lost)

    self.attacker.save!
    self.victim.save!
  end

  VTM = {
    :dice => 10,
    :critical_failure => 1,
    :critical_success => 10,
    :success => 6
  }

  def calculate_dices(attacker, victim)
    attack_points = attacker.attack_points
    defence_points = victim.defence_points
    attack_bonus = 1
    defence_bonus = 1

    # Считаем считаем наносимые повреждения
    attack = []

    # Бросаем кости
    attack_dices = attack_points.d(VTM[:dice])

    # Выбираем критичные успехи и бросаем на каждый дополнительный кубик
    attack_dices.select { |value| value == VTM[:critical_success] }.each do
      attack_dices << 1.d(VTM[:dice]).to_a
    end

    # Собираем все успешные броски
    attack_dices.each do |value|
      attack.push(value) if value >= VTM[:success]
    end

    # Выбираем критичные неудачи и на каждую вычитаем один успех
    attack_dices.select { |value| value == VTM[:critical_failure] }.each do
      attack.pop
    end

    # Считаем считаем компенсируемые повреждения
    defence = []

    # Бросаем кости
    defence_dices = defence_points.d(VTM[:dice])

    # Выбираем критичные успехи и бросаем на каждый дополнительный кубик
    defence_dices.select { |value| value == VTM[:critical_success] }.each do
      defence_dices << 1.d(VTM[:dice]).to_a
    end

    # Собираем все успешные броски
    defence_dices.each do |value|
      defence.push(value) if value >= VTM[:success]
    end

    # Выбираем критичные неудачи и на каждую вычитаем один успех
    defence_dices.select { |value| value == VTM[:critical_failure] }.each do
      defence.pop
    end

    # Summarize successful dices
    attack  = attack.summarize.to_f * attack_bonus
    defence = defence.summarize.to_f * defence_bonus

    # Make sure that both attack and defence are at least 1
    attack = 1 if attack == 0
    defence = 1 if defence == 0

    logger.debug <<-CODE
      Attack: #{attack_points} * #{attack_bonus} = #{attack} 
      Defence Points: #{defence_points} * #{defence_bonus} = #{defence}
CODE

    attacker_won = (attack >= defence)

    attacker_damage_reduce  = 0.01 * attacker.assignments.effect_value(:fight_damage)
    victim_damage_reduce    = 0.01 * victim.assignments.effect_value(:fight_damage)

    if attacker_won
      attack_damage   = rand(victim.health * 1000) * (0.3 - victim_damage_reduce)
      defence_damage  = rand(attack_damage * defence / attack) * (1 - attacker_damage_reduce)
    else
      defence_damage  = rand(attacker.health * 1000) * (0.3 - attacker_damage_reduce)
      attack_damage   = rand(defence_damage * attack / defence) * (1 - victim_damage_reduce)
    end

    return [attacker_won, (attack_damage / 1000).ceil, (defence_damage / 1000).ceil]
  end
end
