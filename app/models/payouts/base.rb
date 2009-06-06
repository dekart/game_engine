module Payouts
  class Base
    cattr_accessor :types

    attr_accessor :value, :options, :action

    def self.inherited(base)
      Payouts::Base.types ||= []
      Payouts::Base.types << base
    end

    def self.payout_name
      self.to_s.demodulize.underscore
    end

    def self.by_name(name)
      "Payouts::#{name.to_s.classify}".constantize
    end

    def initialize(value, options = {})
      @value    = value.to_i
      @options  = options
    end

    def name
      self.class.payout_name
    end

    def apply(character)
      
    end

    def applicable?(trigger)
      (self.options[:apply_on].to_sym == trigger) && (self.options[:chance].to_i > rand(100))
    end
  end
end