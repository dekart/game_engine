namespace :app do
  namespace :maintenance do
    desc "Recalculate character rating"
    task :recalculate_rating => :environment do
      Character.find_.each do |character|
        character.send(:recalculate_rating)
        character.save
      end
    end

    desc "Mark all relations as friends"
    task :mark_relations_as_friends => :environment do
      Relation.update_all "type='FriendRelation'"
    end

    desc "Link all help requests to missions"
    task :link_help_requests_to_missions => :environment do
      HelpRequest.update_all("context_type = 'Mission'")
      Fight.update_all("cause_type = 'Fight'", "cause_id IS NOT NULL")
    end

    desc "Link all help requests to missions"
    task :remove_help_requests_not_missions => :environment do
      HelpRequest.delete_all("context_type != 'Mission'")
      Fight.delete_all("cause_type != 'Fight'")
    end

    desc "Add counter caches to character"
    task :character_counter_caches => :environment do
      Character.update_all("fights_won = (SELECT COUNT(*) FROM fights WHERE winner_id = characters.id)")
      Character.update_all("fights_lost = (SELECT COUNT(*) FROM fights WHERE (attacker_id = characters.id OR victim_id = characters.id) AND winner_id != characters.id)")
      Character.update_all("missions_succeeded = (SELECT sum(win_count) FROM ranks WHERE character_id = characters.id)")
      Character.update_all("missions_completed = (SELECT count(*) FROM ranks WHERE character_id = characters.id AND completed = 1)")

      Character.update_all("relations_count = (SELECT count(*) FROM relations WHERE source_id = characters.id)")
    end

    desc "Group properties"
    task :group_properties => :environment do
      property_types = PropertyType.all

      total = Character.count
      i = 1

      Character.find_each(:batch_size => 100) do |character|
        puts "Processing character #{i}/#{total}"
        
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

        i+= 1
      end
    end

    desc "Group inventories"
    task :group_inventories => :environment do
      puts "Processing item effects"
      
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

      total = Character.count

      i = 1
      
      Character.find_each do |character|
        puts "Processing character #{i}/#{total}"
        
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
          
          character.inventories.calculate_used_in_fight!
        end

        i+= 1
      end
    end
  end
end