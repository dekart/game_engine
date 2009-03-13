class Character < ActiveRecord::Base
  LEVELS = [0]

  70.times do |i|
    LEVELS[i + 1] = LEVELS[i].to_i + (i + 1) * 10
  end


  belongs_to :user
  has_many :ranks
  has_many :missions, :through => :ranks
  has_many :inventories
  has_many :items, :through => :inventories

  attr_accessor :level_updated

  before_save :update_level_and_points

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
      self.increment(name)
      self.decrement(:points)
    end

    return true
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
