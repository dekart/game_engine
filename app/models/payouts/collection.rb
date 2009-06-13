module Payouts
  class Collection
    attr_reader :items

    delegate :each, :empty?, :size, :to => :items

    def initialize(*payouts)
      @items = payouts
    end

    def apply(character, trigger)
      returning result = Payouts::Collection.new do
        self.items.each do |payout|
          if payout.applicable?(trigger)
            payout.apply(character)

            result.items << payout
          end
        end
      end
    end

    def by_action(action)
      self.items.select{|p| p.action == action }
    end
  end
end