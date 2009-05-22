class ItemGroup < ActiveRecord::Base
  has_many :items

  acts_as_list

  named_scope :visible_in_shop, :conditions => "display_in_shop = 1"

  validates_uniqueness_of :name
end
