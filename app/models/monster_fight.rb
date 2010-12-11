class MonsterFight < ActiveRecord::Base
  belongs_to :character
  belongs_to :monster
  
  cattr_reader :damage_system
  @@damage_system = FightingSystem::PlayerVsMonster::Simple

  attr_reader :experience, :money, :character_damage, :monster_damage, :stamina, :payouts

  def attack!
    if monster.progress? && character.sp > 0
      @character_damage, @monster_damage = self.class.damage_system.calculate_damage(character, monster)

      @experience = monster.experience
      @money      = monster.money

      @stamina = 1

      character.sp  -= @stamina

      character.hp  -= @character_damage
      monster.hp    -= @monster_damage

      self.damage   += @monster_damage

      character.experience += @experience

      character.charge(- @money, 0)

      transaction do
        save!
        monster.save!
        character.save!
      end
    else
      false
    end
  end

  def collect_reward!
    return false unless reward_collectable?

    transaction do
      @payouts = monster.monster_type.payouts.apply(character, repeat_fight? ? :repeat_victory : :victory, monster.monster_type)

      character.save!

      self.reward_collected = true

      save!
    end
  end

  def reward_collectable?
    monster.won? && !reward_collected?
  end

  def stamina_requirement
    Requirements::StaminaPoint.new(:value => 1)
  end

  def repeat_fight?
    fights_won = character.monsters.count(:conditions => {:monster_type_id => monster.monster_type_id, :state => 'won'})

    if monster.won?
      fights_won > 1
    else
      fights_won > 0
    end
  end

  def payout_triggers
    if reward_collected?
      []
    elsif repeat_fight?
      [:repeat_victory]
    else
      [:victory]
    end
  end
end
