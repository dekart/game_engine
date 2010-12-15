class Gift < ActiveRecord::Base
  belongs_to :character
  belongs_to :item

  has_many :receipts, :class_name => "GiftReceipt" do
    def sent_to!(facebook_ids)
      transaction do
        facebook_ids.each do |id|
          proxy_owner.receipts.create!(
            :facebook_id => id
          )
        end
      end
    end
  end

  attr_accessor :inventory
end
