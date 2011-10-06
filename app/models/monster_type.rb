class MonsterType < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements
  include HasVisibility

  has_many :monsters

  state_machine :initial => :hidden do
    state :hidden
    state :visible
    state :deleted

    event :publish do
      transition :hidden => :visible
    end

    event :hide do
      transition :visible => :hidden
    end

    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
  end

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x120>",
      :normal => "200x200>",
      :large  => "350x350>",
      :stream => "90x90#"
    },
    :removable => true

  has_requirements

  has_payouts :victory, :repeat_victory, :fight_start, :success, :repeat_success, :invite,
    :apply_on => [:victory, :repeat_victory]

  validates_presence_of :name, :level, :health, :attack, :defence, :experience, :money, :fight_time,
    :minimum_damage, :maximum_damage, :minimum_response, :maximum_response
  validates_numericality_of :level, :attack, :defence, :experience, :money, :fight_time,
    :minimum_damage, :maximum_damage, :minimum_response, :maximum_response, :maximum_reward_collectors,
    :allow_nil    => true,
    :greater_than => 0
    
  def number_of_maximum_reward_collectors
    maximum_reward_collectors || Setting.i(:monsters_maximum_reward_collectors)
  end
  
  def average_response
    (minimum_response + maximum_response) / 2
  end
  
  def applicable_payouts
    if global_payout = GlobalPayout.by_alias('monsters')
      payouts + global_payout.payouts
    else
      payouts
    end
  end
end
