module Requirements
  class Collection
    attr_reader :items

    delegate :each, :empty?, :size, :to => :items

    def initialize(*requirements)
      @items = requirements
    end

    def satisfies?(character)
      items.find{|r|
        not r.satisfies?(character)
      }.nil?
    end
  end
end