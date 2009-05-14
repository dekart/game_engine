module Requirements
  class Collection
    attr_reader :requirements

    delegate :each, :to => :requirements

    def initialize(*requirements)
      @requirements = requirements
    end

    def satisfies?(character)
      self.requirements.find{|r| 
        not r.satisfies?(character)
      }.nil?
    end
  end
end