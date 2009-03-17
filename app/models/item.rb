class Item < ActiveRecord::Base
  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :price }
  }

  named_scope :weapons, { :conditions => "type = 'Weapon'" }
  named_scope :armors,  { :conditions => "type = 'Armor'"  }
end
