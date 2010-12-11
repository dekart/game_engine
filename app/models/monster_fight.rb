class MonsterFight < ActiveRecord::Base
  belongs_to :character
  belongs_to :monster
  
  cattr_reader :damage_system
  @@damage_system = FightingSystem::PlayerVsMonster::Simple

  attr_reader :experience, :money, :character_damage, :monster_damage, :stamina, :payouts

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

  protected

  def repeat_fight?
    character.monster_fights(
      :joins => :monster, :conditions => {:monster_type_id => monster.monster_type_id, :state => 'won'}
    ).count > 1
  end

  def validate_on_create
    errors.add(:character, :not_enough_stamina) if character.sp < 1
    errors.add(:monster, :already_done) unless monster.progress?
  end
end
