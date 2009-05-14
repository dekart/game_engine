module Requirements
  class Base
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def name
      @name ||= self.class.to_s.underscore.split("/").last
    end

    def satisfies?(character)
      return true
    end
  end
end