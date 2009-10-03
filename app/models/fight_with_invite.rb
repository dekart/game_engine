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

    @experience = (attacker.level * Configuration[:fight_with_invite_experience] * 0.01).ceil
    @money      = rand(attacker.level * Configuration[:fight_with_invite_money_max]) + attacker.level * Configuration[:fight_with_invite_money_min]

    @victim_hp_loss = (
      rand(attacker.health * Configuration[:fight_with_invite_victim_damage_max] * 0.01) +
      attacker.health * Configuration[:fight_with_invite_victim_damage_min] * 0.01
    ).ceil
    @attacker_hp_loss = rand((@victim_hp_loss * Configuration[:fight_with_invite_attacker_damage] * 0.01).ceil) + 1
  end

  def valid?
    @valid ||= enough_energy? and !@attacker.weak?
  end

  def enough_energy?
    @attacker.ep >= Configuration[:fight_with_invite_energy_required]
  end

  def save
    @attacker.basic_money += @money
    @attacker.experience  += @experience
    @attacker.hp          -= @attacker_hp_loss
    @attacker.ep          -= Configuration[:fight_with_invite_energy_required]

    @attacker.save
  end
end