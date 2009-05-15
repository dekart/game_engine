class Mission < ActiveRecord::Base
  has_many :ranks

  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :level }
  }

  serialize :requirements, Requirements::Collection
  serialize :payouts, Payouts::Collection
end
