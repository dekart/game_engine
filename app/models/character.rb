class Character < ActiveRecord::Base
  LEVELS = [0]

  70.times do |i|
    LEVELS[i + 1] = LEVELS[i].to_i + (i + 1) * 10
  end

  HP_REFILL_PERIOD = 2.minutes + 30.seconds
  EP_REFILL_PERIOD = 5.minutes
  HP_PER_REFILL = 1
  EP_PER_REFILL = 1

  belongs_to :user
  has_many :ranks
  has_many :missions, :through => :ranks
  has_many :inventories, :include => :item do
    def attack
      if most_powerful_weapon = self.weapons.first
        return most_powerful_weapon.attack
      else
        return 0
      end
    end

    def defence
      if most_powerful_armor = self.armors.first
        return most_powerful_armor.defence
      else
        return 0
      end
    end
  end
  
  has_many :attacks, :class_name => "Fight", :foreign_key => :attacker_id
  has_many :defences, :class_name => "Fight", :foreign_key => :victim_id
  has_many :won_fights, :class_name => "Fight", :foreign_key => :winner_id

  attr_accessor :level_updated

  before_create :refill_hp, :refill_ep
  before_save :update_level_and_points
  before_save :schedule_hp_ep_refill

  named_scope :victims_for, Proc.new{|attacker|
    {
      :conditions => [
        %{
          (level BETWEEN :low_level AND :high_level) AND
          characters.id NOT IN (
            SELECT fights.victim_id FROM fights WHERE attacker_id = :attacker_id AND winner_id = :attacker_id AND fights.created_at > :time_limit
          ) AND
          characters.id != :attacker_id
        },
        {
          :low_level    => attacker.level,
          :high_level   => attacker.level + 2,
          :attacker_id  => attacker.id,
          :time_limit   => 1.hour.ago
        }
      ],
      :include  => :user
    }
  }

  def fulfill_mission!(mission)
    return false if self.ep < mission.ep_cost

    rank = mission.by(self)
    
    self.class.transaction do
      rank.increment(:win_count)
      rank.save!

      self.decrement(:ep, mission.ep_cost)
      self.increment(:experience, mission.experience)
      self.increment(:basic_money, mission.money)
      self.save!
    end

    return rank
  end

  def upgrade_attribute!(name)
    return false unless %w{attack defence health energy}.include?(name.to_s) && self.points > 0

    ActiveRecord::Base.transaction do
      self.increment(name, (name.to_sym == :health ? 5 : 1))
      self.decrement(:points)

      self.save
    end

    return true
  end

  def attack_points
    self.attack + self.inventories.attack
  end

  def defence_points
    self.defence + self.inventories.defence
  end

  def refill_hp(amount = nil, refilled_at = nil)
    self.hp += amount || self.health

    if self.hp >= self.health
      self.hp = self.health
      self.hp_refilled_at = nil
    else
      self.hp_refilled_at = refilled_at || Time.now
    end
  end

  def refill_ep(amount = nil, refilled_at = nil)
    self.ep += amount || self.energy

    if self.ep >= self.energy
      self.ep = self.energy
      self.ep_refilled_at = nil
    else
      self.ep_refilled_at = refilled_at || Time.now
    end
  end

  def refill_hp_and_ep!
    if self.hp < self.health and Time.now - self.hp_refilled_at > HP_REFILL_PERIOD
      refill_times = (Time.now - self.hp_refilled_at).to_i / HP_REFILL_PERIOD
      
      self.refill_hp(HP_PER_REFILL * refill_times, self.hp_refilled_at + refill_times * HP_REFILL_PERIOD)
    end

    if self.ep < self.energy and Time.now - self.ep_refilled_at > EP_REFILL_PERIOD
      refill_times = (Time.now - self.ep_refilled_at).to_i / EP_REFILL_PERIOD

      self.refill_ep(EP_PER_REFILL * refill_times, self.ep_refilled_at + refill_times * EP_REFILL_PERIOD)
    end

    self.save
  end

  def weak?
    self.hp < self.weakness_minimum
  end

  def weakness_minimum
    (self.health * 0.2).ceil
  end

  def hp_restore_time(restore_to = nil)
    restore_to ||= self.health

    if self.hp >= restore_to
      return 0
    else
      (self.hp_refilled_at + ((restore_to - self.hp) / HP_PER_REFILL * HP_REFILL_PERIOD).to_i) - Time.now
    end
  end

  def ep_restore_time(restore_to = nil)
    restore_to ||= self.health

    if self.ep >= restore_to
      return 0
    else
      (self.ep_refilled_at + ((restore_to - self.ep) / EP_PER_REFILL * EP_REFILL_PERIOD).to_i) - Time.now
    end
  end

  def experience_to_next_level
    self.next_level_experience - self.experience
  end

  def next_level_experience
    LEVELS[self.level]
  end
  
  protected

  def update_level_and_points
    if self.experience_to_next_level <= 0
      self.level  += 1
      self.points += 5

      self.level_updated = true
    end
  end

  def schedule_hp_ep_refill
    self.hp_refilled_at = Time.now if self.hp_changed? and self.hp_was > self.hp
    self.ep_refilled_at = Time.now if self.ep_changed? and self.ep_was > self.ep
  end
end
