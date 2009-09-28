class Character
  module Properties
    def give(type, amount = 1)
      if property = find_by_property_type_id(type.id)
        property.amount += amount
      else
        property = build(:property_type => type, :amount => amount)
      end

      property
    end

    def give!(type, amount = 1)
      property = give(type, amount)

      proxy_owner.recalculate_income if property.save

      property
    end

    def buy!(type, amount = 1)
      property = give(type, amount)

      property.charge_money = true

      proxy_owner.recalculate_income if property.save

      property
    end

    def sell!(type, amount = 1)
      if property = find_by_property_type_id(type.id)
        property.deposit_money = true

        if property.amount > amount
          property.amount -= amount
          property.save
        else
          property.destroy
        end

        proxy_owner.recalculate_income

        property
      else
        false
      end
    end

    def take!(type, amount = 1)
      if property = find_by_property_type_id(type.id)
        if property.amount > amount
          property.amount -= amount
          property.save
        else
          property.destroy
        end

        proxy_owner.recalculate_income

        property
      else
        false
      end
    end
  end
end