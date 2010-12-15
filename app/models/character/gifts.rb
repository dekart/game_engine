class Character
  module Gifts
    def self.included(base)
      base.class_eval do
        has_many :gifts, :extend => GiftsAssociationExtension
        has_many :gift_receipts,
          :through  => :gifts,
          :source   => :receipts
      end
    end

    module GiftsAssociationExtension
      def has_unaccepted?
        GiftReceipt.unaccepted.for_character(proxy_owner).count > 0
      end

      def accept!(id)
        if id.to_sym == :all
          gift_receipts = GiftReceipt.unaccepted.for_character(proxy_owner)
        elsif gift = Gift.find_by_id(id)
          gift_receipts = gift.receipts.unaccepted.for_character(proxy_owner)
        else
          gift_receipts = []
        end

        gift_receipts.map do |receipt|
          receipt.gift.inventory = receipt.give_item!
          receipt.gift
        end
      end
    end
  end
end