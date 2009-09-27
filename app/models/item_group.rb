class ItemGroup < ActiveRecord::Base
  has_many :items, :dependent => :destroy

  acts_as_list

  named_scope :visible_in_shop, :conditions => "display_in_shop = 1", :order => "position"

  validates_uniqueness_of :name
end
