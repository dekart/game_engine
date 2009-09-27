namespace :app do
  namespace :maintenance do
    desc "Group properties"
    task :group_properties => :environment do
      property_types = PropertyType.all

      Character.find_each(:batch_size => 100) do |character|
        properties = property_types.inject({}) do |result, type|
          count = character.properties.count(:conditions => ["property_type_id = ?", type.id])
          
          result[type] = count if count > 0
          result
        end

        Character.transaction do
          character.properties.delete_all

          properties.each do |type, amount|
            character.properties.give(type, amount)
          end

          character.save
          
          character.recalculate_income
        end
      end
    end

    desc "Group inventories"
    task :group_inventories => :environment do
      Character.find_each do |character|
        items = character.inventories.inject({}) do |result, inventory|
          result[inventory.item] ||= 0
          result[inventory.item] += 1
          result
        end

        Character.transaction do
          character.inventories.delete_all

          items.each do |item, amount|
            character.inventories.give(item, amount)
          end

          character.save
        end
      end

      Item.find_each do |item|
        collection = Effects::Collection.new

        item.effects.each do |effect|
          if effect.is_a?(YAML::Object)
            case effect.class
            when "Effects::Attack"
              item.attack = effect.ivars["value"]
            when "Effects::Defence"
              item.defence = effect.ivars["value"]
            end
          else
            collection << Effects::Collection.new(effect)
          end
        end

        item.effects = collection

        item.save
      end
    end
  end
end