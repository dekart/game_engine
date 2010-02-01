module Requirements
  class Base
    class Errors
      def on(*args)
      end
    end

    cattr_accessor :types

    attr_accessor :value

    class << self
      def inherited(base)
        Requirements::Base.types ||= []
        Requirements::Base.types << base
      end

      def requirement_name
        self.to_s.demodulize.underscore
      end

      def by_name(name)
        "Requirements::#{name.to_s.classify}".constantize
      end

      def human_attribute_name(field)
        I18n.t(field,
          :scope    => [:requirements, self.to_s.demodulize.underscore, :attributes],
          :default  => I18n.t(field,
            :scope    => [:requirements, :base, :attributes],
            :default  => field.humanize
          )
        )
      end
    end

    def initialize(options = {})
      @value = options[:value].to_i
    end

    def name
      self.class.requirement_name
    end

    def errors
      Errors.new
    end

    def satisfies?(character)
      return true
    end
  end
end