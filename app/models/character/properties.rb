class Character
  module Properties
    def give!(type)
      find_by_property_type_id(type.id) || create(:property_type => type)
    end

    def buy!(type)
      unless property = find_by_property_type_id(type.id)
        property = build(:property_type => type)

        property.buy!
      end

      property
    end

    def collect_money!
      result = Payouts::Collection.new
      
      transaction do
        each do |property|
          if collected = property.collect_money!
            result += collected
          end
        end
      end

      result.any? ? result : false
    end

    def collectable
      unless @collectable
        @collectable = []
        
        each do |property|
          @collectable << property if property.collectable?
        end
      end

      @collectable
    end
  end
end