class MissionLevel < ActiveRecord::Base
  extend HasRequirements
  extend HasPayouts
  extend HasEvents

  default_scope :order => "mission_levels.position"

  belongs_to :mission, :counter_cache => :levels_count
  has_many   :ranks,
    :class_name   => "MissionLevelRank",
    :foreign_key  => :level_id,
    :dependent    => :delete_all


  acts_as_list :scope => :mission_id

  has_requirements

  has_payouts :success, :failure, :repeat_success, :repeat_failure, :level_complete,
    :apply_on => :level_complete
    
  has_events(:success, :failure, :repeat_success, :repeat_failure, :level_complete,
    :bind_to => :mission_group_complete
  )

  validates_presence_of :win_amount, :chance, :energy, :experience, :money_min, :money_max
  validates_numericality_of :win_amount, :chance, :energy, :experience, :money_min, :money_max, :allow_blank => true

  after_create :update_completion_status

  def money
    money_min == money_max ? money_min : (rand(money_max - money_min) + money_min)
  end

  def energy_requirement
    Requirements::EnergyPoint.new(:value => energy)
  end
  
  def applicable_requirements
    requirements + mission.applicable_requirements
  end

  def applicable_payouts
    payouts + mission.applicable_payouts
  end

  def applicable_events
    events + mission.applicable_events
  end

  protected

  def update_completion_status
    mission.ranks.update_all({:completed => false}, {:completed => true})
    mission.mission_group.ranks.update_all({:completed => false}, {:completed => true})
  end
end
