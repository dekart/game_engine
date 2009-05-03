class BankOperation < ActiveRecord::Base
  belongs_to :character

  attr_accessible :amount

  validates_numericality_of :amount, :greater_than => 0, :only_integer => true
end
