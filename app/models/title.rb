class Title < ActiveRecord::Base
  acts_as_dropdown :order => "name"

  validates_uniqueness_of :name
end
