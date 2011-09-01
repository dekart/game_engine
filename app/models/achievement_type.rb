class AchievementType < ActiveRecord::Base
  extend HasPayouts

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
      :icon   => "50x50>",
      :medium => "120x120#",
      :stream => "90x90#"
    },
    :removable => true

  has_payouts :achieve, :visible => true

  validates_presence_of     :name, :key, :value
  validates_numericality_of :value, :allow_blank => true
end
