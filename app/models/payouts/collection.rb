module Payouts
  class Collection
    attr_reader :payouts

    delegate :each, :empty?, :to => :payouts

    def initialize(*payouts)
      @payouts = payouts
    end

    def apply(character, trigger)
      returning result = Payouts::Collection.new do
        self.payouts.each do |payout|
          if payout.applicable?(trigger)
            payout.apply(character)

            result.payouts << payout
          end
        end
      end
    end

    def by_action(action)
      self.payouts.select{|p| p.action == action }
    end
  end
end