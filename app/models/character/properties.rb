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
      result = 0
      
      transaction do
        each do |property|
          if collected = property.collect_money!
            result += collected
          end
        end
      end

      result > 0 ? result : false
    end
  end
end