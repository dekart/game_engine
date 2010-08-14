module Requirements
  class Collection
    attr_reader :items

    delegate :each, :empty?, :size, :to => :items

    def self.parse(collection)
      return if collection.nil?

      if collection.is_a?(Requirements::Collection)
        collection
      else
        items = collection.values.sort_by{|v| v["position"].to_i }.collect do |requirement|
          requirement.symbolize_keys!

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
  end
end