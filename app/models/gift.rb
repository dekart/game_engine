class Gift < ActiveRecord::Base
  belongs_to :character
  belongs_to :item

  has_many :receipts, :class_name => "GiftReceipt"
end
