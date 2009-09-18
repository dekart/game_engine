class FightWithInvite
  attr_accessor :attacker, :victim, :experience, :money, :victim_hp_loss, :attacker_hp_loss

  def self.create(options = {})
    fight = new(options[:attacker], options[:victim])

    fight.save if fight.valid?

    fight
  end

  def initialize(attacker, victim_id)
    @attacker = attacker
    @victim   = victim_id

    @experience = (attacker.level * 0.5).ceil
    @money      = rand(attacker.level * 10) + attacker.level * 5

    @victim_hp_loss = (rand(attacker.health * 0.25) + attacker.health * 0.1).ceil
    @attacker_hp_loss = rand((@victim_hp_loss * 0.8).ceil) + 1
  end

  def valid?
    @valid ||= enough_energy? and !@attacker.weak?
  end

  def enough_energy?
    @attacker.ep > 0
  end

  def save
    @attacker.basic_money += @money
    @attacker.experience  += @experience
    @attacker.hp          -= @attacker_hp_loss
    @attacker.ep          -= 1

    @attacker.save
  end
end