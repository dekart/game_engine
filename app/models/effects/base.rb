module Effects
  class Base
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def name
      @name ||= self.class.to_s.underscore.split("/").last
    end

    def +(effect)
      self.value += effect.value
    end
  end
end