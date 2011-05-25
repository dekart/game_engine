class MonsterFight < ActiveRecord::Base
  belongs_to :character
  belongs_to :monster

  named_scope :top_damage, :order => "damage DESC", :include => :character
  
  cattr_reader :damage_system
  @@damage_system = FightingSystem::PlayerVsMonster::Simple

  attr_reader :experience, :money, :character_damage, :monster_damage, :stamina, :payouts
  
  validates_uniqueness_of :character_id, :scope => :monster_id, :on => :create
  
  after_create :create_character_news

  # @power_attack - this is usual attack but effects multiplied by special factor
  def attack!(power_attack = false)
    monster.expire if monster.time_remaining <= 0
    
    if monster.progress? && character.sp >= stamina_limit(power_attack) && !character.weak?
      @character_damage, @monster_damage = self.class.damage_system.calculate_damage(character, monster)

      @experience = monster.experience
      @money      = monster.money

      @stamina = 1

      power_attack_effect if power_attack
      
      attack_actions
      
      transaction do
        save!
        monster.save!
        character.save!

        if monster.won?
          character.news.add(:monster_fight_defeat, :monster_fight_id => id)
        end
      end
      
      true
    else
      false
    end
  end
  
  def stamina_limit(power_attack = false)
    power_attack ? Setting.i(:monster_fight_power_attack_factor) : 1
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
    !new_record? && monster.won? && !reward_collected? && significant_damage?
  end

  def stamina_requirement(power_attack = false)
    Requirements::StaminaPoint.new(:value => stamina_limit(power_attack))
  end

  def repeat_fight?
    character.monster_fights.count(
      :joins => :monster,
      :conditions => [
        'monsters.monster_type_id = ? AND monster_fights.reward_collected = ?', monster.monster_type_id, true
      ]
    ) > 0
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
  
  def significant_damage?
    damage >= Setting.p(:monster_minimum_damage, monster.monster_fights.maximum(:damage))
  end
  
  def summoner?
    character == monster.character
  end

  def event_data
    {
      :reference_id => self.id,
      :reference_type => "Monster",
      :reference_damage => -self.monster_damage,
      :health => -self.character_damage,
      :basic_money => self.money,
      :stamina => -self.stamina,
      :experience => self.experience
    }
  end

  protected
  
    def attack_actions
      character.sp  -= @stamina

      character.hp  -= @character_damage
      monster.hp    -= @monster_damage

      self.damage   += @monster_damage

      character.experience += @experience

      character.charge(- @money, 0, :monster_attack)
    end
  
    def power_attack_effect
      power_factor = Setting.i(:monster_fight_power_attack_factor)
      
      @character_damage *= power_factor
      @monster_damage *= power_factor
      @experience *= power_factor
      @money *= power_factor
      @stamina *= power_factor
    end
  
    def create_character_news
      character.news.add(:monster_fight_start, :monster_fight_id => id)
    end
end
