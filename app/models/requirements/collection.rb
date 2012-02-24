module Requirements
  class Collection
    attr_reader :items

    delegate :<<, :shift, :unshift, :each, :empty?, :any?, :size, :first, :last, :[], :to => :items

    def self.parse(collection)
      return if collection.blank?

      if collection.is_a?(Requirements::Collection)
        collection
      else
        collection = collection.values.sort_by{|v| v["position"].to_i } if collection.is_a?(Hash)
        
        items = collection.collect do |requirement|
          requirement = requirement.symbolize_keys

          Requirements::Base.by_name(requirement[:type]).new(requirement.except(:type, :position))
        end

        new(*items)
      end
    end

    def initialize(*requirements)
      @items = requirements
    end

    def satisfies?(character)
      items.find{|r|
        not r.satisfies?(character)
      }.nil?
    end

    def +(other)
      Requirements::Collection.new.tap do |result|
        result.items.push(*items)
        result.items.push(*other.items)
      end
    end
  end
end
