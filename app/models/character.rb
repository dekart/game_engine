class Character < ActiveRecord::Base
  belongs_to :user
  has_many :ranks
  has_many :missions, :through => :ranks
  has_many :inventories
  has_many :items, :through => :inventories
end
