module Payouts
  class Collection
    attr_reader :payouts

    delegate :each, :to => :payouts

    def initialize(*payouts)
      @payouts = payouts
    end

    def apply(character, trigger)
      returning result = [] do
        self.payouts.each do |payout|
          result << payout.apply(character) if payout.options[:apply_on] == trigger
        end
      end
    end
  end
end