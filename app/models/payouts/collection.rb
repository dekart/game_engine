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
          if payout.options[:apply_on] == trigger &&
             (payout.options[:chance].nil? || (rand(100) <= payout.options[:chance]))
            result << payout.apply(character)
          end
        end

        result.compact!
      end
    end
  end
end