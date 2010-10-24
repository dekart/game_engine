class PurchasedBoost < ActiveRecord::Base
  belongs_to :character
  belongs_to :boost

  delegate(*(%w[attack defence damage] + [{:to => :boost}]))
end
