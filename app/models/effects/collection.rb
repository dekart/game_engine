module Effects
  class Collection
    attr_reader :items

    delegate :each, :empty?, :size, :to => :items

    def initialize(*effects)
      @items = effects
    end

    def [](key)
      if key.is_a?(Numeric)
        self.items[key]
      else
        klass = Effects::Base.by_name(key)

        self.items.find{|e| e.class == klass } || klass.new(0)
      end
    end

    def <<(collection)
      collection.items.each do |effect|
        if existing = self.items.find{|e| e.class == effect.class }
          existing += effect
        else
          self.items << effect
        end
      end
    end

    def apply(character)
      self.each do |effect|
        effect.apply(character)
      end
    end
  end
end