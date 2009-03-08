class Character < ActiveRecord::Base
  belongs_to :user
  has_many :ranks
  has_many :quests, :through => :ranks
  has_many :inventories
  has_many :items, :through => :inventories
end
