module Effects
  class Base
    cattr_accessor :types
    
    attr_accessor :value

    def self.inherited(base)
      Effects::Base.types ||= []
      Effects::Base.types << base
    end

    def self.effect_name
      self.to_s.demodulize.underscore
    end

    def self.by_name(name)
      "Effects::#{name.to_s.classify}".constantize
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