class UpgradeRecipe < ActiveRecord::Base

  belongs_to :item
  belongs_to :result, :class_name => "Item"

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

  validates_presence_of :item, :result
  validates_numericality_of :price, :greater_than => 0

end