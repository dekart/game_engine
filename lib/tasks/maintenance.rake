namespace :app do
  namespace :maintenance do
    desc "Migrate configuration values to settings"
    task :move_configuration_to_settings => :environment do
      puts "Moving configuration to settings"

      if config = ActiveRecord::Base.connection.select_all("SELECT * FROM configurations").first
        config.except("id").each do |key, value|
          Setting[key] = value
        end

        puts "Done!"
      else
        puts "Configuration not found"
      end
    end

    desc "Auto-equip inventories"
    task :auto_equip_inventories => :environment do
      count = Inventory.equippable.count

      puts "Equipping #{count} inventories..."

      Inventory.equippable.all(:include => [{:character => :character_type}, :item], :order => "items.vip_price DESC, items.basic_price DESC").each_with_index do |inventory, index|
        inventory.character.equipment.auto_equip!(inventory)

        puts "Equipped #{index}/#{count} inventories..." if index % 10 == 0
      end

      puts "Done!"
    end

    desc "Set default states to objects"
    task :set_default_states => :environment do
      %w{bosses item_groups items mission_groups missions property_types}.each do |t|
        t.classify.constantize.update_all "state = 'visible'"
      end
    end

    desc "Update translation strings to use interpolations"
    task :translations_to_interpolations => :environment do
      puts "Modifying interpolations for #{Translation.count} translations..."

      Translation.find_each do |t|
        t.value = t.value.gsub(/([^\{]|\A)\{([^\{])/, "\\1{{\\2")
        t.value = t.value.gsub(/([^\}])\}([^\}]|\Z)/, "\\1}}\\2")
        t.save!
      end

      puts "Done!"
    end

    desc "Update payout triggers"
    task :update_payout_events => :environment do
      Promotion.all.each do |pr|
        pr.payouts.each do |p|
          p.apply_on = :success
        end

        pr.save
      end
    end

    desc "Set default values to owned items"
    task :set_defaults_to_owned_items => :environment do
      Item.update_all "owned = 0", "owned IS NULL"
    end

    desc "Calculate owned_items"
    task :calculate_owned_items => :environment do
      Item.find_each do |item|
        item.update_attribute(:owned, item.inventories.sum(:amount))
      end
    end

    desc "Move item, mission, and property images"
    task :move_images_to_new_urls => :environment do
      [Item, Mission, PropertyType, MissionGroup].each do |klass|
        total = klass.count

        klass.find_each do |item|
          puts "Processing #{klass.to_s.humanize} #{item.id}/#{total}..."

          if item.image?
            old_file_name = File.join(RAILS_ROOT, "public", "system", "images", item.id.to_s, "original", item.image_file_name)

            if File.file?(old_file_name)
              item.image = File.open(old_file_name)
              item.save!
            else
              puts "File not found: #{old_file_name}"
            end
          end
        end
      end
    end

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