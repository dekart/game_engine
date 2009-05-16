class ItemGroup < ActiveRecord::Base
  has_many :items

  acts_as_list

  validates_uniqueness_of :name
end
