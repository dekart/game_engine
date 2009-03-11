class Character < ActiveRecord::Base
  belongs_to :user
  has_many :ranks
  has_many :missions, :through => :ranks
  has_many :inventories
  has_many :items, :through => :inventories

  def fulfill_mission!(mission)
    rank = self.ranks.find_or_initialize_by_mission_id(mission.id)
    
    self.class.transaction do
      rank.increment(:win_count)
      rank.save!

      self.decrement(:ep, mission.ep_cost)
      self.increment(:experience, mission.experience)
      self.increment(:money, mission.money)
      self.save!
    end
  end
end
