class MonsterFight < ActiveRecord::Base
  belongs_to :character
  belongs_to :monster
  
  cattr_reader :damage_system
  @@damage_system = FightingSystem::PlayerVsMonster::Simple

  attr_reader :experience, :money, :character_damage, :monster_damage, :stamina

  def attack!
    if valid?
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
    end
  end

  def reward_collectable?
    monster.won? && !reward_collected?
  end

  protected

  def validate
    errors.add(:character, :not_enough_stamina) if character.sp < 1
    errors.add(:monster, :already_done) unless monster.progress?
  end
end
