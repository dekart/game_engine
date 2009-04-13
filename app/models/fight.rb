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
      self.errors.add(:character, "You don't have enough energy to fight. Take a rest!")
    end

    if Character.victims_for(self.attacker).find(:first, :conditions => {:id => self.victim.id}).nil?
      self.errors.add(:character, "You cannot attack this user")
    end

    if self.attacker.weak?
      self.errors.add(:character, "You are too weak to fight! Take a rest!")
    end
  end

  def calculate_fight
    attacker_won, self.victim_hp_loss, self.attacker_hp_loss = calculate_dices(self.attacker, self.victim)

    self.winner = attacker_won ? self.attacker : self.victim

    self.experience = rand((self.loser.level.to_f / 2).ceil).to_i
    self.money = rand((self.loser.basic_money.to_f * 0.10).ceil).to_i
  end

  def save_payout
    self.winner.increment(:experience, self.experience)

    self.winner.increment(:basic_money, self.money)
    self.loser.decrement(:basic_money, self.money)

    self.attacker.ep  -= 1

    self.attacker.hp  -= self.attacker_hp_loss
    self.victim.hp    -= self.victim_hp_loss

    self.attacker.save!
    self.victim.save!
  end

  VTM = {
    :dice => 10,
    :critical_failure => 1,
    :critical_success => 1,
    :success => 5
  }

  def calculate_dices(attacker, victim)
    attack_points = attacker.attack_points
    defence_points = victim.defence_points
    attack_bonus = 1.1
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

    # Суммируем значения успешных бросков
    attack  = attack.summarize.to_f * attack_bonus
    defence = defence.summarize.to_f * defence_bonus

    logger.debug "Attack: %f * %f = %f \nDefence Points: %f * %f = %f" % [
      attack_points, attack_bonus, attack,
      defence_points, defence_bonus, defence
    ]

    return [attack >= defence, (attack / 2).ceil, (defence / 2).ceil]
  end
end
