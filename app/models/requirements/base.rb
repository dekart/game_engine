module Requirements
  class Base
    class Errors
      def on(*args)
      end
    end

    cattr_accessor :types

    attr_accessor :value, :visible

    class << self
      def inherited(base)
        Requirements::Base.types ||= []
        Requirements::Base.types << base
      end

      def requirement_name
        to_s.demodulize.underscore
      end

      def by_name(name)
        "Requirements::#{name.to_s.classify}".constantize
      end

      def human_attribute_name(field)
        I18n.t(field,
          :scope    => [:requirements, requirement_name, :attributes],
          :default  => I18n.t(field,
            :scope    => [:requirements, :base, :attributes],
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
      self.class.requirement_name
    end

    def errors
      Errors.new
    end

    def value=(value)
      @value = value.to_i
    end

    def visible=(value)
      if value == true || value == false
        @visible = value
      else
        @visible = (value.to_i != 0)
      end
    end
    
    def visible
      @visible.nil? ? true : @visible # This is required to make all previously created requirements visible
    end

    def satisfies?(character)
      true
    end
  end
end
