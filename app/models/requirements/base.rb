module Requirements
  class Base
    cattr_accessor :types

    attr_accessor :value

    def self.inherited(base)
      Requirements::Base.types ||= []
      Requirements::Base.types << base
    end

    def self.requirement_name
      self.to_s.demodulize.underscore
    end

    def self.by_name(name)
      "Requirements::#{name.to_s.classify}".constantize
    end

    def initialize(value)
      @value = value.to_i
    end

    def name
      self.class.requirement_name
    end

    def satisfies?(character)
      return true
    end
  end
end