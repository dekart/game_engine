class MissionLevel < ActiveRecord::Base
  extend HasPayouts

  default_scope :order => "mission_levels.position"

  belongs_to :mission

  acts_as_list :scope => :mission_id

  has_payouts :success, :failure, :complete, :repeat_success, :repeat_failure,
    :default_event => :complete

  validates_presence_of :win_amount, :chance, :energy, :experience, :money_min, :money_max
  validates_numericality_of :win_amount, :chance, :energy, :experience, :money_min, :money_max, :allow_blank => true
end