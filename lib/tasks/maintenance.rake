namespace :app do
  namespace :maintenance do
    desc "Update translation keys"
    task :update_translation_keys => :environment do
      puts "Updating translation keys..."

      {
        "characters.level_up.title"             => "notifications.level_up.title",
        "characters.level_up.text"              => "notifications.level_up.text",
        "characters.level_up.upgrade_link"      => "notifications.level_up.upgrade_link",
        "characters.level_up.buttons.continue"  => "notifications.level_up.buttons.continue",
        "characters.level_up.buttons.upgrade"   => "notifications.level_up.buttons.upgrade"
      }.each do |old_key, new_key|
        if translation = Translation.find_by_key(old_key)
          print "#{old_key} - "

          if new_key.present?
            translation.update_attribute(:key, new_key)
            
            puts "Updated"
          else
            translation.destroy

            puts "Deleted"
          end
        end
      end

      puts "Done!"
    end

    # One-time tasks

    desc "Move mission titles to a separate model"
    task :move_mission_titles_to_model => :environment do
      puts "Moving mission titles..."

      i = 0

      Mission.find_each do |mission|
        next if mission.title.blank?

        title = Title.find_or_create_by_name(mission.title)

        mission.ranks.all(:conditions => {:completed => true}, :include => :character).each do |rank|
          rank.character.titles << title
        end

        mission.title = nil
        mission.payouts << Payouts::Title.new(:value => title)
        mission.save!

        i += 1
      end

      puts "Moved #{i} titles."

      puts "Moving group titles..."

      i = 0

      MissionGroup.find_each do |group|
        next if group.title.blank?

        title = Title.find_or_create_by_name(group.title)

        group.mission_group_ranks.all(:conditions => {:completed => true}, :include => :character).each do |rank|
          rank.character.titles << title
        end

        group.title = nil
        group.payouts << Payouts::Title.new(:value => title)
        group.save!

        i += 1
      end

      puts "Moved #{i} titles."
      
      puts "Done!"
    end

    desc "Make sure that friend relations are etsablished in both directions"
    task :check_friend_relations => :environment do
      puts "Checking friend relations (#{FriendRelation.count})..."

      restored = 0

      FriendRelation.find_each do |relation|
        unless FriendRelation.first(:conditions => {:owner_id => relation.character_id, :character_id => relation.owner_id})
          FriendRelation.create(
            :owner      => relation.character,
            :character  => relation.owner
          )
          
          restored += 1
        end
      end

      puts "Done! #{restored} relations restored"
    end

    desc "Assign attributes to mercenries"
    task :assign_attributes_to_mercenaries => :environment do
      puts "Assigning attributes to mercenaries..."

      MercenaryRelation.transaction do
        MercenaryRelation.find_each do |relation|
          relation.send(:copy_owner_attributes)

          relation.save!
        end
      end

      puts "Done!"
    end

    desc "Update total money for characters"
    task :update_total_money_for_characters => :environment do
      Character.update_all "total_money = basic_money + bank"
    end

    desc "Invert visibility settings"
    task :invert_visibility_settings => :environment do
      puts "Inverting visibility settings..."

      Visibility.all(:select => "DISTINCT target_id, target_type").collect(&:target).each do |target|
        puts "%s #%s" % [target.class, target.id]

        Visibility.transaction do
          types_to_add = (CharacterType.all - target.visibilities.character_types)

          target.visibilities.delete_all

          types_to_add.each do |type|
            target.visibilities.create!(:character_type => type)
          end
        end
      end
      
      puts "Done!"
    end

    desc "Migrate items to payout-based usage system"
    task :use_payouts_for_item_effects => :environment do
      puts "Deleting legacy translations..."
      
      Translation.delete_all "`key` LIKE 'inventories.use.button%'"

      puts "Hiding currently usable items..."

      Item.scoped(:conditions => {:usable => true}).each do |item|
        item.update_attribute(:usable, false)
        item.hide

        item.inventories.update_all "amount = amount * #{item.usage_limit || 1}"
      end

      puts "Done!"
    end

    desc "Reprocess ass images"
    task :reprocess_images => :environment do
      [Boss, Mission, PropertyType, MissionGroup, CharacterType, Item].each do |klass|
        puts "Reprocessing #{klass.to_s} images (#{klass.count})..."

        klass.all.each do |instance|
          instance.image.reprocess!
        end
      end
    end

    desc "Migrate configuration values to settings"
    task :move_configuration_to_settings => :environment do
      puts "Moving configuration to settings"

      if config = ActiveRecord::Base.connection.select_all("SELECT * FROM configurations").first
        config.except("id", "created_at", "updated_at").each do |key, value|
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