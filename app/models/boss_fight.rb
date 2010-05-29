class BossFight < ActiveRecord::Base
  belongs_to :boss
  belongs_to :character

  named_scope :latest, :order => "created_at DESC"

  state_machine :initial => :progress do
    state :progress
    state :won
    state :lost
    state :expired

    event :win do
      transition :progress => :won
    end

    event :lose do
      transition :progress => :lost
    end
    
    event :expire do
      transition :progress => :expired
    end
  end

  attr_reader :winner, :boss_hp_loss, :character_hp_loss, :payouts, :group_rank, :group_payouts

  delegate :experience, :ep_cost, :mission_group, :time_limit?, :to => :boss

  before_create :get_energy_from_character
  
  def perform!
    if time_left <= 0
      perform_expire!
    elsif progress? && valid?
      attacker_won, @boss_hp_loss, @character_hp_loss = calculate_proportions

      @winner = attacker_won ? character : boss

      self.character.hp -= @character_hp_loss
      self.health       -= @boss_hp_loss

      self.class.transaction do
        if boss_lost?
          self.character.experience += boss.experience

          @payouts = boss.payouts.apply(character, 
            character.boss_fights.won?(boss) ? :repeat_victory : :victory
          )
          
          self.win!

          @group_rank, @group_payouts = character.mission_groups.check_completion!(boss.mission_group)
        elsif character_lost?
          @payouts = boss.payouts.apply(character,
            character.boss_fights.won?(boss) ? :repeat_defeat : :defeat
          )

          self.lose!
        end

        save
        character.save!
      end
    end
  end

  def perform_expire!
    self.class.transaction do
      @payouts = boss.payouts.apply(character, :failure)

      expire!

      save
      character.save!
    end
  end

  def boss_lost?
    health <= 0
  end

  def character_lost?
    character.hp <= 0
  end

  def time_left
    (expire_at - Time.now).to_i
  end

  def health=(value)
    self[:health] = (value >= 0 ? value : 0)
  end

  def received_something?
    won? || (@payouts && @payouts.by_action(:add).any?)
  end

  def lost_something?
    lost? || expired? || (@payouts && @payouts.by_action(:remove).any?)
  end

  def requirements_satisfied?
    @requirements_satisfied ||= boss.requirements.satisfies?(character)
  end

  def enough_energy?
    character.ep >= ep_cost
  end

  protected

  def validate_on_create
    errors.add(:character, :already_won) if !boss.repeatable && character.boss_fights.won?(boss)
    
    errors.add(:character, :not_enough_energy) if !enough_energy?

    errors.add(:character, :too_weak) if character.weak?

    errors.add(:character, :requirements_not_satisfied) unless requirements_satisfied?
  end

  def get_energy_from_character
    self.character.ep -= self.ep_cost
  end

  def calculate_proportions
    attack_points   = character.attack
    defence_points  = boss.defence
    attack_bonus    = 1.0
    defence_bonus   = 1.0

    attack = attack_points * attack_bonus * 50
    defence = defence_points * defence_bonus * 50

    attacker_won = (rand((attack + defence).to_i) >= defence)

    if attacker_won
      attack_damage   = Setting.p(:boss_max_loser_damage, rand(boss.health * 1000))
      defence_damage  = rand(
        attack > defence ? (attack_damage * defence / attack) : Setting.p(:boss_max_winner_damage, attack_damage)
      )
    else
      defence_damage  = rand(Setting.p(:boss_max_loser_damage, character.health * 1000))
      attack_damage   = rand(
        defence > attack ? (defence_damage * attack / defence) : Setting.p(:boss_max_winner_damage, defence_damage)
      )
    end

    return [attacker_won, (attack_damage / 1000).ceil, (defence_damage / 1000).ceil]
  end
end