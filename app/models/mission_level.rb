class MissionLevel < ActiveRecord::Base
  extend HasPayouts

  default_scope :order => "mission_levels.position"

  belongs_to :mission, :counter_cache => :levels_count

  acts_as_list :scope => :mission_id

  has_payouts :success, :failure, :complete, :repeat_success, :repeat_failure,
    :default_event => :complete

  validates_presence_of :win_amount, :chance, :energy, :experience, :money_min, :money_max
  validates_numericality_of :win_amount, :chance, :energy, :experience, :money_min, :money_max, :allow_blank => true

  after_create :update_completion_status

  def money
    rand(money_max - money_min) + money_min
  end

  def energy_requirement
    Requirements::EnergyPoint.new(:value => energy)
  end

  protected

  def update_completion_status
    mission.ranks.update_all({:completed => false}, {:completed => true})
    mission.mission_group.ranks.update_all({:completed => false}, {:completed => true})
  end
end
