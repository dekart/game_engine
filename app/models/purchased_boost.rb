class PurchasedBoost < ActiveRecord::Base
  belongs_to :character
  belongs_to :boost
end
