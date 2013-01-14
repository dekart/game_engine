class MonsterFight < ActiveRecord::Base
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

  attr_reader :experience, :money, :character_damage, :monster_damage, :stamina, :payouts, :boost

  delegate :monster_type, :time_remaining, :to => :monster

  validates_uniqueness_of :character_id, :scope => :monster_id, :on => :create

  after_create  :create_character_news, :add_to_active_fights
  after_save    :update_damage_score

  # @power_attack - this is usual attack but effects multiplied by special factor
  def attack!(boost = nil, power_attack = false)
    monster.expire if monster.time_remaining <= 0

    if monster.progress? && character.sp >= stamina_limit(power_attack) && !character.weak? && character.hp >= hp_average_response_limit(power_attack)
      @character_damage, @monster_damage = self.class.damage_system.calculate_damage(character, monster)

      @boost = character.boosts.for(:monster, :attack).detect{ |b| b.item_id == boost }

      @experience = monster.experience
      @money      = monster.money

      @stamina = 1

      @payouts = monster_type.applicable_payouts.apply(character, power_attack ? :repeat_success : :success)

      power_attack_effect if power_attack

      attack_actions

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
      @payouts = monster_type.applicable_payouts.apply_with_result(character, payout_triggers, monster_type)

      character.save!

      self.reward_collected = true

      character.monster_types.collected.clear_cache!

      save!

      add_to_finished_fights
    end

    true
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

  def boosts
    character.boosts.for(:monster, :attack).
      sort_by{ |i| i.item.effect(:damage) }.reverse[0..1].
      map{ |i| [i.item_id, i.amount, i.item.effect(:damage), i.pictures.url(:medium)] }
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

  def basic_payouts
    monster_type.applicable_payouts.preview(payout_triggers)
  end

  def as_json
    {
      :fight_id => self.id,
      :boosts   => boosts,
      :monster  => monster.as_json,
      :damage   => damage,
      :minimum_damage   => minimum_damage,
      :maximum_damage   => maximum_damage,
      :reward           => basic_payouts.as_json,
      :reward_collectable => reward_collectable?,
      :reward_collected => reward_collected?,
      :will_get_reward  => will_get_reward?,
      :time_remaining   => time_remaining,
      :power_attack_factor => Setting.i(:monster_fight_power_attack_factor)
    }
  end

  def add_to_active_fights
    character.monster_fights.add_to_active(self)
  end

  def add_to_defeated_fights
    character.monster_fights.add_to_defeated(self)
  end

  def add_to_finished_fights
    character.monster_fights.add_to_finished(self)
  end

  def minimum_damage
    monster.minimum_damage
  end

  def maximum_damage
    monster.maximum_damage
  end

  protected

    def attack_actions
      character.sp  -= @stamina

      character.hp  -= @character_damage

      @monster_damage += @boost.effect(:damage) if @boost
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
      true
    end

    def update_damage_score
      monster.damage.set(character, damage)
    end
end
