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
      :small  => "100x100>",
      :normal => "200x200>"
    },
    :removable => true

  has_requirements

  has_payouts :victory, :defeat, :repeat_victory, :repeat_defeat,
    :default_event => :victory

  validates_presence_of :name, :level, :health, :attack, :defence, :experience, :money, :fight_time, :cooling_time
  validates_numericality_of :level, :attack, :defence, :experience, :money, :fight_time, :cooling_time,
    :allow_nil    => true,
    :greater_than => 0
end
