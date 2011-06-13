class CreditPackage < ActiveRecord::Base
  default_scope :order => "vip_money"

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

  validates_presence_of :vip_money, :price
  validates_numericality_of :vip_money, :price, :allow_blank => true, :greater_than => 0
end
