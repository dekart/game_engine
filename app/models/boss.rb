class Boss < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements
  extend HasPictures
  include HasVisibility

  belongs_to  :mission_group
  has_many    :boss_fights, :dependent => :delete_all

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

  has_pictures :styles => [
    [:normal => "200x200>"],
    [:small  => "100x100>"],
    [:stream => "90x90#"],
    [:icon   => "40x40#"]
  ]

  has_requirements

  has_payouts :victory, :defeat, :repeat_victory, :repeat_defeat

  validates_presence_of     :mission_group, :name, :health, :attack, :defence, :ep_cost, :experience
  validates_numericality_of :health, :attack, :defence, :ep_cost, :time_limit, :experience, :allow_blank => true

  def time_limit?
    time_limit.to_i > 0
  end
end
