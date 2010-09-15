class Collection < ActiveRecord::Base
  extend HasPayouts

  has_payouts :collected
  
  validates_presence_of :name

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

  def item_ids
    self[:item_ids].to_s.split(",")
  end

  def item_ids=(value)
    self[:item_ids] = value.is_a?(Array) ? value.join(",") : value
  end

  def items
    Item.find_all_by_id(item_ids)
  end
end
