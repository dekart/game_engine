module Event
  class Base
    class Errors
      def on(*args)
      end
    end

    cattr_accessor :types

    attr_accessor :value, :visible

    class << self
      def inherited(base)
        Event::Base.types ||= []
        Event::Base.types << base
      end

      def event_name
        to_s.demodulize.underscore
      end

      def by_name(name)
        "Event::#{name.to_s.classify}".constantize
      end

      def human_attribute_name(field)
        I18n.t(field,
          :scope    => [:events, event_name, :attributes],
          :default  => I18n.t(field,
            :scope    => [:events, :base, :attributes],
            :default  => field.humanize
          )
        )
      end
    end

    def initialize(attributes = {})
      attributes.each_pair do |key, value|
        send("#{key}=", value)
      end
    end

    def name
      self.class.event_name
    end

    def trigger!(character, reference = nil)
      raise "Not implemented"
    end

    def bound_to?(*triggers)
      (bind_to & triggers).present? && Dice.chance(chance, 100)
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

    def bind_to
      if @bind_to.is_a?(Array)
        @bind_to
      elsif !@bind_to.nil?
        [@bind_to]
      else
        [:complete]
      end
    end

    def bind_to=(values)
      @bind_to = Array(values).collect{|value| value.to_sym }
    end

    def trigger_label
      bind_to.collect{|value| value.to_s.humanize }.join(", ")
    end
  end
end
