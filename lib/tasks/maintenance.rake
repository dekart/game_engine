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
  end
end