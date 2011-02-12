class GlobalPayout < ActiveRecord::Base
  extend HasPayouts

  validates_presence_of :name, :alias
  
  has_payouts :success

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
end
