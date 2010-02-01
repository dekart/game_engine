module Payouts
  class Base
    class Errors
      def on(*args)
      end
    end

    ACTIONS = [:add, :remove]
    
    cattr_accessor :types

    attr_accessor :value, :visible

    class << self
      def inherited(base)
        Payouts::Base.types ||= []
        Payouts::Base.types << base
      end

      def payout_name
        self.to_s.demodulize.underscore
      end

      def by_name(name)
        "Payouts::#{name.to_s.classify}".constantize
      end

      def human_attribute_name(field)
        I18n.t(field,
          :scope    => [:payouts, self.to_s.demodulize.underscore, :attributes],
          :default  => I18n.t(field,
            :scope    => [:payouts, :base, :attributes],
            :default  => field.humanize
          )
        )
      end
    end

    def initialize(attributes = {})
      attributes.each_pair do |key, value|
        self.send("#{key}=", value)
      end
    end

    def name
      self.class.payout_name
    end

    def apply(character)
      
    end

    def applicable?(trigger)
      (self.apply_on == trigger) && (self.chance > rand(100))
    end

    def errors
      Errors.new
    end

    def chance
      @chance ||= 100
    end

    def chance=(value)
      @chance = value.to_i
    end

    def apply_on
      @apply_on || :complete
    end

    def apply_on=(value)
      @apply_on = value.to_sym
    end

    def action
      @action || :add
    end

    def action=(value)
      @action = value.to_sym
    end

    def visible=(value)
      @visible = (value.to_i == 1)
    end
  end
end