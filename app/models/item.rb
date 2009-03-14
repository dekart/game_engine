class Item < ActiveRecord::Base
  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :price }
  }
end
