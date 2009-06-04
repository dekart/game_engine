module Effects
  class Base
    cattr_accessor :types
    
    attr_accessor :value

    def self.inherited(base)
      Effects::Base.types ||= []
      Effects::Base.types << base
    end

    def initialize(value)
      @value = value
    end

    def self.effect_name
      self.to_s.underscore.split("/").last
    end

    def self.by_name(name)
      "Effects::#{name.to_s.classify}".constantize
    end

    def name
      self.class.effect_name
    end

    def +(effect)
      self.value += effect.value
    end
  end
end