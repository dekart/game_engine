class Item < ActiveRecord::Base
  has_attached_file :image, :styles => {:small => "100x100#", :medium => "150x150#"}

  extend SerializeEffects
  serialize_effects :effects

  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :basic_price }
  }

  named_scope :weapons, { :conditions => "type = 'Weapon'" }
  named_scope :armors,  { :conditions => "type = 'Armor'"  }
end
