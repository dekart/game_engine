class Item < ActiveRecord::Base
  has_attached_file :image,
    :styles => {
      :small  => "72x72#",
      :medium => "120x120#",
      :large  => "200x200#",
      :belt   => "84x24#"
    }

  extend SerializeEffects
  serialize_effects :effects

  named_scope :available_for, Proc.new {|character|
    { :conditions => ["level <= ?", character.level], :order => :basic_price }
  }

  named_scope :weapons, { :conditions => "type = 'Weapon'" }
  named_scope :armors,  { :conditions => "type = 'Armor'"  }

  named_scope :shop, {:conditions => "availability = 'shop'"}
end
