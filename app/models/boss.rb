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
  has_payouts

  validates_presence_of     :mission_group, :name, :health
  validates_numericality_of :health, :allow_blank => true
end
