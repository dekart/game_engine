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
    if expired?
      perform_expire!
    elsif valid?
      attacker_won, @boss_hp_loss, @character_hp_loss = calculate_proportions

      @winner = attacker_won ? character : boss

      self.character.hp -= @character_hp_loss
      self.health       -= @boss_hp_loss

      self.class.transaction do
        if boss_lost?
          self.character.experience += boss.experience

          @payouts = boss.payouts.apply(character, :complete)

          self.win!

          @group_rank, @group_payouts = character.mission_groups.check_completion!(boss.mission_group)
        elsif character_lost?
          @payouts = boss.payouts.apply(character, :failure)

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

  protected

  def validate_on_create
    self.errors.add(:character, :not_enough_energy) if character.ep < ep_cost

    self.errors.add(:character, :too_weak) if character.weak?
  end

  def get_energy_from_character
    self.character.ep -= self.ep_cost
  end

  def calculate_proportions
    attack_points = character.attack_points
    defence_points = boss.defence
    attack_bonus = 1.0
    defence_bonus = 1.0

    attack = attack_points * attack_bonus * 50
    defence = defence_points * defence_bonus * 50

    attacker_won = (rand((attack + defence).to_i) >= defence)

    if attacker_won
      attack_damage   = rand(boss.health * 1000) * Configuration[:boss_max_loser_damage] * 0.01
      defence_damage  = rand(attack_damage * (attack > defence ? defence / attack : Configuration[:boss_max_winner_damage] * 0.01))
    else
      defence_damage  = rand(character.health * 1000) * Configuration[:boss_max_loser_damage] * 0.01
      attack_damage   = rand(defence_damage * (defence > attack ? attack / defence : Configuration[:boss_max_winner_damage] * 0.01))
    end

    return [attacker_won, (attack_damage / 1000).ceil, (defence_damage / 1000).ceil]
  end
end