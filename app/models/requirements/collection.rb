module Requirements
  class Collection
    attr_reader :items

    delegate :each, :to => :items

    def initialize(*requirements)
      @items = requirements
    end

    def satisfies?(character)
      self.items.find{|r|
        not r.satisfies?(character)
      }.nil?
    end
  end
end