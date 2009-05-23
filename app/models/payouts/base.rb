module Payouts
  class Base
    attr_accessor :value, :options, :action

    def initialize(value, options = {})
      @value    = value
      @options  = options
    end

    def name
      @name ||= self.class.to_s.underscore.split("/").last
    end

    def apply(character)
      
    end

    def applicable?
      self.options[:chance].nil? || (self.options[:chance] >= rand(100))
    end
  end
end