class Character < ActiveRecord::Base
  LEVELS = [0]

  70.times do |i|
    LEVELS[i + 1] = LEVELS[i].to_i + (i + 1) * 10
  end

  belongs_to :user
  has_many :ranks
  has_many :missions, :through => :ranks
  has_many :inventories, :include => :item do
    def attack
      if most_powerful_weapon = self.weapons.find(:first, :order => "attack DESC")
        return most_powerful_weapon.attack
      else
        return 0
      end
    end

    def defence
      if most_powerful_armor = self.armors.find(:first, :order => "defence DESC")
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

  before_save :update_level_and_points

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

    rank = self.ranks.find_or_initialize_by_mission_id(mission.id)
    
    self.class.transaction do
      rank.increment(:win_count)
      rank.save!

      self.decrement(:ep, mission.ep_cost)
      self.increment(:experience, mission.experience)
      self.increment(:money, mission.money)
      self.save!
    end

    return true
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

  protected

  def update_level_and_points
    if self.experience >= LEVELS[self.level]
      self.level  += 1
      self.points += 5

      self.level_updated = true
    end
  end
end
