module Event
  class Collection
    attr_reader :items

    delegate :<<, :shift, :unshift, :each, :empty?, :any?, :size, :first, :last, :[], :detect, :include?, :to => :items

    def self.parse(collection)
      return if collection.blank?
      return collection if collection.is_a?(self)

      items = collection.values.sort_by{|v| v["position"].to_i }.collect do |event|
        event.symbolize_keys!

        Event::Base.by_name(event[:type]).new(event.except(:type, :position))
      end

      new(*items)
    end

    def initialize(*events)
      @items = events
    end

    def trigger!(character, trigger)
      by_trigger(trigger).tap do |events|
        events.each do |event| 
          event.trigger!(character, reference)
        end
      end
    end
    
    def by_trigger(trigger)
      Event::Collection.new.tap do |result|
        items.each do |event|
          if event.bound_to?(*trigger)
            result << payout
          end
        end
      end
    end

    def +(other)
      Event::Collection.new.tap do |result|
        result.push(*items)
        result.push(*other.items)
      end
    end

    def to_s
      items.collect{|i| i.to_s }.join("; ")
    end
  end
end
