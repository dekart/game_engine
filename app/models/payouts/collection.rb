module Payouts
  class Collection
    attr_reader :items

    delegate :<<, :shift, :unshift, :each, :empty?, :any?, :size, :first, :last, :[], :detect, :include?, :to => :items

    def self.parse(collection)
      return if collection.blank?

      if collection.is_a?(Payouts::Collection)
        collection
      else
        items = collection.values.sort_by{|v| v["position"].to_i }.collect do |payout|
          payout = payout.symbolize_keys

          Payouts::Base.by_name(payout[:type]).new(payout.except(:type, :position))
        end

        new(*items)
      end
    end

    def initialize(*payouts)
      @items = payouts
    end

    # TODO: this method should be replaced with 'apply_with_result' everywhere
    def apply(character, trigger, reference = nil)
      reward = Reward.new(character, reference)

      find_all(trigger).tap do |payouts|
        payouts.each {|payout| payout.apply(character, reward, reference) }
      end
    end

    def apply_with_result(character, trigger, reference = nil)
      Reward.new(character, reference) do |result|
        find_all(trigger).each do |payout|
          payout.apply(character, result, reference)
        end
      end
    end

    def find_all(trigger)
      Payouts::Collection.new.tap do |result|
        items.each do |payout|
          if payout.applicable?(*trigger)
            result.items << payout
          end
        end
      end
    end

    def preview(trigger)
      Reward.new(nil) do |reward|
        find_all(trigger).each do |payout|
          payout.preview(reward)
        end
      end
    end

    def by_action(action)
      items.select{|p| p.action == action }
    end

    def payout_include?(name)
      !self.detect{ |p| p.class == Payouts::Base.by_name(name) }.nil?
    end

    def visible?
      !items.detect{|i| i.visible }.nil?
    end

    def +(other)
      Payouts::Collection.new.tap do |result|
        result.items.push(*items)
        result.items.push(*other.items)
      end
    end

    def to_s
      items.collect{|i| i.to_s }.join("; ")
    end
  end
end
