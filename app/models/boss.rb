class Boss < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements

  belongs_to :mission_group
  
  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "100x100>",
      :normal => "200x200>"
    }

  has_requirements
  
  has_payouts :victory, :defeat, :repeat_victory, :repeat_defeat,
    :default_event => :victory

  validates_presence_of     :mission_group, :name, :health, :attack, :defence, :ep_cost, :experience
  validates_numericality_of :health, :attack, :defence, :ep_cost, :time_limit, :experience, :allow_blank => true

  def time_limit?
    time_limit.to_i > 0
  end
end
