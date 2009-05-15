module Payouts
  class Base
    attr_accessor :value, :options

    def initialize(value, options = {})
      @value    = value
      @options  = options
    end

    def name
      @name ||= self.class.to_s.underscore.split("/").last
    end

    def apply(character)
      
    end
  end
end