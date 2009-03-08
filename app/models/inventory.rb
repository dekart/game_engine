class Inventory < ActiveRecord::Base
  belongs_to :character
  belongs_to :item
end
