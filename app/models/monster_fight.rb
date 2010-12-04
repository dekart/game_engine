class MonsterFight < ActiveRecord::Base
  belongs_to :character
  belongs_to :monster
  
  cattr_reader :damage_system
  @@damage_system = nil

  def attack!
    if valid?
      character_damage, monster_damage = self.class.damage_system.calculate_damage(character, monster)

      character.sp -= 1
      
      character.hp  -= character_damage
      monster.hp    -= monster_damage

      self.damage   += monster_damage

      character.experience += monster.experience
      character.charge(- monster.money, 0)

      transaction do
        monster.save!
        character.save!
        save!
      end
    end
  end

  protected

  def validate
    errors.add(:character, :not_enough_stamina) if character.sp < 1
    errors.add(:monster, :already_done) unless monster.progress?
  end
end
