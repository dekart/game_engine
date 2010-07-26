class VipMoneyOperation < ActiveRecord::Base
  belongs_to :character

  attr_accessible :amount, :reference

  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than => 0, :only_integer => true

  def reference=(value)
    case value
    when ActiveRecord::Base
      self.reference_id   = value.id
      self.reference_type = value.class.sti_name
    when Array
      self.reference_type = value.first
      self.reference_id   = value.last
    else
      self.reference_type = value
    end
  end
end
