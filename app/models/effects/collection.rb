module Effects
  class Collection
    attr_reader :effects

    delegate :each, :to => :effects

    def initialize(*effects)
      @effects = effects
    end

    def [](key)
      klass = "Effects::#{key.to_s.classify}".constantize

      self.effects.find{|e| e.class == klass } || klass.new(0)
    end

    def <<(collection)
      collection.effects.each do |effect|
        if existing = self.effects.find{|e| e.class == effect.class }
          existing += effect
        else
          self.effects << effect
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