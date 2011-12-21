module Effects
  class Base
    class Errors
      def on(*args)
      end
    end
    
    BASIC_TYPES = [:attack, :defence, :health, :energy, :stamina, 
      :hp_restore_rate, :sp_restore_rate, :ep_restore_rate
    ]
    COMPLEX_TYPES = []
    
    cattr_accessor :types

    attr_accessor :value
    
    class << self
      def inherited(base)
        Effects::Base.types ||= []
        Effects::Base.types << base
      end

      def effect_name
        to_s.demodulize.underscore
      end

      def by_name(name)
        "Effects::#{name.to_s.camelize}".constantize
      end

      def human_attribute_name(field)
        I18n.t(field,
          :scope    => [:effects, effect_name, :attributes],
          :default  => I18n.t(field,
            :scope    => [:effects, :base, :attributes],
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
      self.class.effect_name
    end

    def apply(character, reference = nil)
      raise "Not implemented"
    end

    def errors
      Errors.new
    end
    
    def value=(value)
      @value = value.to_i
    end
    
    def to_hash
      {:type => name.to_sym, :value => value}
    end
  end
end