class PropertyType < ActiveRecord::Base
  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x>"
    }

  named_scope :available_for, Proc.new {|character|
    {
      :conditions => ["level <= ?", character.level],
      :order      => :basic_price
    }
  }
end
