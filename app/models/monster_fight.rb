class MonsterFight < ActiveRecord::Base
  POWER_ATTACK = 5

  belongs_to :character
  belongs_to :monster

  scope :top_damage, :order => "damage DESC", :include => :character

  scope :own,
    :joins      => :monster,
    :conditions => 'monsters.character_id = monster_fights.character_id'

  scope :by_type, Proc.new{|type|
    {
      :joins => :monster,
      :conditions => ["monsters.monster_type_id = ?", type.id]
    }
  }

  scope :by_monster, Proc.new{|monster|
    {
      :conditions => {:monster_id => monster}
    }
  }

  cattr_reader :damage_system
  @@damage_system = FightingSystem::PlayerVsMonster::Simple

  attr_reader :experience, :money, :character_damage, :monster_damage, :stamina, :reward, :boost

  delegate :monster_type, :time_remaining, :to => :monster

  validates_uniqueness_of :character_id, :scope => :monster_id, :on => :create

  after_create  :create_character_news, :add_to_active_fights
  after_save    :update_damage_score

  def can_attack?(power_attack)
    if !monster.progress?
      self.errors.add(:base, :can_not_attack)

      false
    elsif character.sp < stamina_limit(power_attack)
      self.errors.add(:base, :not_enough_stamina)

      false
    elsif character.weak? || character.hp < hp_average_response_limit(power_attack)
      self.errors.add(:base, :not_enough_health)

      false
    else
      true
    end
  end

  # @power_attack - this is usual attack but effects multiplied by special factor
  def attack!(boost = nil, power_attack = false)
    monster.expire if monster.time_remaining <= 0

    if can_attack?(power_attack)
      @character_damage, @monster_damage = self.class.damage_system.calculate_damage(character, monster)

      @boost = character.boosts.for(:monster, :attack).detect{ |b| b.item_id == boost }

      if power_attack
        @stamina = POWER_ATTACK

        @character_damage *= POWER_ATTACK
        @monster_damage *= POWER_ATTACK

        @reward = monster_type.apply_reward_on(:power_attack, character)
      else
        @stamina = 1

        @reward = monster_type.apply_reward_on(:attack, character)
      end

      character.sp  -= @stamina
      character.hp  -= @character_damage

      @monster_damage += @boost.effect(:damage) if @boost
      monster.hp    -= @monster_damage

      self.damage   += @monster_damage

      character.total_monsters_damage += @monster_damage

      ActiveSupport::Notifications.instrument(:monster_attack,
        :monster      => monster,
        :stamina      => @stamina,
        :basic_money  => @money,
        :experience   => @experience,
      )

      transaction do
        save!
        monster.save!

        character.inventories.take!(@boost.item) if @boost
        character.save!

        monster.add_fighter(character, @monster_damage)

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
    power_attack ? POWER_ATTACK : 1
  end

  def hp_average_response_limit(power_attack = false)
    monster.monster_type.average_damage * (power_attack ? POWER_ATTACK : 1)
  end

  def collect_reward!
    return false unless reward_collectable?

    transaction do
      @reward = monster_type.apply_reward_on(
        character.monsters.rewarded_monster_types.include?(self) ? :repeat_victory : :victory,
        character
      )

      character.save!

      self.reward_collected = true

      save!

      character.monsters.reward_collected!(self)

      add_to_finished_fights
    end

    @reward
  end

  def reward_collectable?
    !new_record? && monster.won? && !reward_collected? && will_get_reward?
  end

  def will_get_reward?
    monster.will_get_reward?(character)
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
    if reward_collected?
      []
    else
      character.monster_types.payout_triggers(monster_type).tap do |triggers|
        triggers << :invite if accepted_invites_count > 0
      end
    end
  end

  def summoner?
    character == monster.character
  end

  def as_json
    {
      :id => id,
      :monster  => monster.as_json_for(character),
      :damage   => damage,
      :reward_collectable => reward_collectable?,
      :reward_collected => reward_collected?,
      :will_get_reward  => will_get_reward?,
      :time_remaining   => time_remaining,
    }
  end

  def as_json_for_attack
    {
      :monster_damage   => @monster_damage,
      :character_damage => @character_damage,
      :reward => @reward
    }
  end

  def add_to_active_fights
    character.monsters.add_to_active_fights(self)
  end

  def add_to_defeated_fights
    character.monsters.add_to_defeated_fights(self)
  end

  def add_to_finished_fights
    character.monsters.add_to_finished_fights(self)
  end

  protected

    def create_character_news
      character.news.add(:monster_fight_start, :monster_fight_id => id)
      true
    end

    def update_damage_score
      monster.damage.set(character, damage)
    end
end
