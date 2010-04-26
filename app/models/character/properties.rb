class Character
  module Properties
    def give!(type)
      find_by_property_type_id(type.id) || create(:property_type => type)
    end

    def buy!(type)
      unless property = find_by_property_type_id(type.id)
        property = build(:property_type => type)

        property.buy
      end

      property
    end
  end
end