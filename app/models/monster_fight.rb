class MonsterFight < ActiveRecord::Base
  belongs_to :character
  belongs_to :monster

  named_scope :top_damage, :order => "damage DESC", :include => :character
  named_scope :current, Proc.new {
    {
      :joins => :monster,
      :conditions => ["(monsters.defeated_at IS NULL AND monsters.expire_at >= :time) OR (monsters.defeated_at >= :time)",
        {:time => Setting.i(:monsters_reward_time).hours.ago}
      ]
    }
  }
  named_scope :own, 
    :joins      => :monster,
    :conditions => 'monsters.character_id = monster_fights.character_id'
  named_scope :by_type, Proc.new{|type|
    {
      :joins => :monster,
      :conditions => ["monsters.monster_type_id = ?", type.id]
    }
  }
  
  
  cattr_reader :damage_system
  @@damage_system = FightingSystem::PlayerVsMonster::Simple

  attr_reader :experience, :money, :character_damage, :monster_damage, :stamina, :payouts
  
  delegate :monster_type, :to => :monster
  
  validates_uniqueness_of :character_id, :scope => :monster_id, :on => :create
  
  after_create :create_character_news

  # @power_attack - this is usual attack but effects multiplied by special factor
  def attack!(power_attack = false)
    monster.expire if monster.time_remaining <= 0
    
    if monster.progress? && character.sp >= stamina_limit(power_attack) && !character.weak? && character.hp >= hp_average_response_limit(power_attack)
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
          monster.killer = character
          monster.save!
          
          # update stats for killer and player, who inited attack
          if character != monster.character
            monster.character.killed_monsters_count += 1
            monster.character.save!
          end 
          
          character.killed_monsters_count += 1
          character.save!
          
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
  
  def hp_average_response_limit(power_attack = false)
    monster.average_response * (power_attack ? Setting.i(:monster_fight_power_attack_factor) : 1)
  end
  
  def collect_reward!
    return false unless reward_collectable?

    transaction do
      @payouts = monster_type.payouts.apply(character, character.monster_types.payout_triggers(monster_type), monster_type)

      character.save!

      self.reward_collected = true
      
      character.monster_types.collected.clear_cache!

      save!
    end
  end

  def reward_collectable?
    !new_record? && monster.won? && !reward_collected? && significant_damage?
  end

  def stamina_requirement(power_attack = false)
    Requirements::StaminaPoint.new(:value => stamina_limit(power_attack))
  end
  
  def hp_average_response_requirement(power_attack = false)
    Requirements::HealthPoint.new(:value => hp_average_response_limit(power_attack))
  end

  def repeat_fight?
    character.monster_types.repeat_fight?(monster_type)
  end

  def payout_triggers
    reward_collected? ? [] : character.monster_types.payout_triggers(monster_type)
  end
  
  def significant_damage?
    # user caused significant damage and was in top damage players
    damage >= Setting.p(:monster_minimum_damage, monster.monster_fights.maximum(:damage)) &&
      monster.monster_fights.top_damage.index(self) < monster_type.number_of_maximum_reward_collectors
  end
  
  def summoner?
    character == monster.character
  end

  def event_data
    {
      :reference_id => self.id,
      :reference_type => "Monster",
      :reference_damage => -self.monster_damage.to_i,
      :health => -self.character_damage.to_i,
      :basic_money => self.money.to_i,
      :stamina => -self.stamina.to_i,
      :experience => self.experience.to_i
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
