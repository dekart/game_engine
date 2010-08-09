module Payouts
  class Collection
    attr_reader :items

    delegate :<<, :each, :empty?, :any?, :size, :first, :last, :[], :to => :items

    def self.parse(collection)
      return if collection.nil?

      if collection.is_a?(Payouts::Collection)
        collection
      else
        items = collection.values.sort_by{|v| v["position"].to_i }.collect do |payout|
          payout.symbolize_keys!
          
          Payouts::Base.by_name(payout[:type]).new(payout.except(:type, :position))
        end

        new(*items)
      end
    end

    def initialize(*payouts)
      @items = payouts
    end

    def apply(character, trigger)
      returning result = Payouts::Collection.new do
        items.each do |payout|
          if payout.applicable?(trigger)
            payout.apply(character)

            result.items << payout
          end
        end
      end
    end

    def by_action(action)
      items.select{|p| p.action == action }
    end

    def +(other)
      returning result = Payouts::Collection.new do
        result.items.push(*items)
        result.items.push(*other.items)
      end
    end
  end
end