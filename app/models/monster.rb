class Monster < ActiveRecord::Base
  belongs_to :monster_type
  belongs_to :character

  delegate :name, :health, :to => :monster_type

  before_create :assign_health_points

  protected

  def assign_health_points
    self.hp = health
  end
end
