module Effects
  class Collection
    attr_reader :items

    delegate :<<, :shift, :unshift, :each, :empty?, :any?, :size, :first, :last, :[], :to => :items

    def self.parse(collection)
      return if collection.blank?
      
      if collection.is_a?(Effects::Collection)
        collection
      else
        items = collection.values.sort_by{|v| v["position"].to_i }.collect do |effect|
          effect.symbolize_keys!
            
          Effects::Base.by_name(effect[:type]).new(effect.except(:type, :position))
        end
        
        new(*items)
      end
    end

    def initialize(*effects)
      @items = effects
    end
    
    def visible?
      !items.detect{|i| i.visible }.nil?
    end
    
    def +(other)
      Effects::Collection.new.tap do |result|
        result.items.push(*items)
        result.items.push(*other.items)
      end
    end
    
    def by_type(type)
      Effects::Collection.new.tap do |result|
        items.each do |effect|
          if effect.name == type.to_s
            result.items << effect
          end
        end
      end
    end
    
    def to_s
      items.collect{|i| i.to_s }.join("; ")
    end
    
    def metric
      items.sum{|i| i.value }
    end
  end
end
