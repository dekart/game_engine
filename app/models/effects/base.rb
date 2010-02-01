module Effects
  class Base
    cattr_accessor :types
    
    attr_accessor :value

    class << self
      def inherited(base)
        Effects::Base.types ||= []
        Effects::Base.types << base
      end

      def effect_name
        self.to_s.demodulize.underscore
      end

      def by_name(name)
        "Effects::#{name.to_s.classify}".constantize
      end
    end

    def initialize(value)
      @value = value.to_i
    end

    def name
      self.class.effect_name
    end

    def +(effect)
      self.value += effect.value
    end
  end
end