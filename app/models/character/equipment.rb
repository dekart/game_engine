class Character
  class Equipment < ActiveRecord::Base

    MAIN_PLACEMENTS = [:right_hand, :left_hand, :head, :body, :legs]
    PLACEMENTS = MAIN_PLACEMENTS + [:additional]

    # A set of placements to be enabled by default
    DEFAULT_PLACEMENTS = []

    IMAGE_SIZES = {
      :left_hand  => :medium,
      :right_hand => :medium,
      :head       => :small,
      :body       => :medium,
      :legs       => :medium,
      :additional => :small
    }

    belongs_to :character

    serialize :placements

    class << self
      def placement_name(name)
        I18n.t("inventories.placements.names.#{name}", :default => name.to_s.humanize)
      end
    end

    def main_placements
      MAIN_PLACEMENTS
    end

    def all_placements
      PLACEMENTS
    end

    def placements
      self[:placements] ||= {}
    end

    def inventories
      unless @inventories
        ids = placements.values.flatten

        if ids.any?
          inventories = Inventory.find_all_by_id(ids.uniq.sort, :include => :item)

          # Sorting inventories by ID order
          @inventories = ids.collect do |id|
            inventories.detect{|inventory| inventory.id == id}
          end
        else
          @inventories = []
        end
      end

      @inventories
    end


    def inventories_by_placement(placement)
      Array.wrap(placements[placement.to_sym]).collect do |id|
        inventories.detect{|i| i.id == id}
      end
    end


    def equip(inventory, placement)
      placement = placement.to_sym

      return unless inventory.placements.include?(placement) && inventory.equippable?

      previous = nil

      if available_capacity(placement) > 0
        placements[placement] ||= []
        placements[placement] << inventory.id

        inventory.equipped = equipped_amount(inventory)
      elsif main_placements.include?(placement) # Main placements can be replaced
        previous = character.inventories.find(placements[placement].last)

        unless previous == inventory # Do not re-equip the same inventory
          unequip(previous, placement)
          equip(inventory, placement)
        end
      end

      @inventories = nil

      previous
    end


    def unequip(inventory, placement)
      placement = placement.to_sym

      if placements[placement] and index = placements[placement].index(inventory.id)
        placements[placement].delete_at(index)

        inventory.equipped = equipped_amount(inventory) unless inventory.frozen?
      end

      @inventories = nil
    end


    def equip!(inventory, placement)
      Character.transaction do

        previous = equip(inventory, placement)

        previous.try(:save)

        inventory.save
        save

        clear_effect_cache!
      end
    end


    def unequip!(inventory, placement)
      Character.transaction do
        unequip(inventory, placement)

        inventory.save
        save

        clear_effect_cache!
      end
    end


    def auto_equip(inventory, amount = nil)
      amount ||= inventory.amount_available_for_equipment

      amount.times do
        if placement = (placements_with_free_slots & inventory.placements).first
          equip(inventory, placement)
        else
          break
        end
      end
    end


    def auto_equip!(inventory, amount = nil)
      Character.transaction do
        auto_equip(inventory, amount)

        inventory.save

        save

        clear_effect_cache!
      end
    end

    def auto_unequip(inventory)
      amount_to_unequip = inventory.destroyed? ? inventory.amount : (inventory.equipped - inventory.amount)

      return if amount_to_unequip <= 0

      amount_to_unequip.times do
        if placement = equipped_slots(inventory).last
          unequip(inventory, placement)
        else
          break
        end
      end
    end


    def auto_unequip!(inventory)
      Character.transaction do
        auto_unequip(inventory)

        inventory.save unless inventory.destroyed?

        save

        clear_effect_cache!
      end
    end


    def equip_best!(force_unequip = false)
      unequip_all! if force_unequip

      equippables = character.inventories.equippable.all

      Character.transaction do
        while free_slots > 0
          equipped = nil

          Effects::Base::BASIC_TYPES.each do |effect|
            candidates = equippables.select{|i| i.equippable? and i.effect(effect) != 0}.sort_by{|i| [i.effect(effect), i.effects.metric]}.reverse

            candidates.each do |inventory|
              if auto_equip(inventory, 1)
                equipped = inventory
                
                break
              end
            end
          end

          break if equipped == nil
        end

        equippables.each do |inventory|
          inventory.save if inventory.changed?
        end

        save

        clear_effect_cache!
      end
    end


    def unequip_all!
      Character.transaction do
        character.inventories.equipped.update_all(:equipped => 0)

        self.placements = {}
        save

        clear_effect_cache!
      end
    end


    def free_slots
      PLACEMENTS.sum{|placement| available_capacity(placement) }
    end


    def available_capacity(placement)
      placement_capacity(placement) - used_capacity(placement)
    end


    def best_offence
      character.inventories.equipped.by_item_id(Item.with_effect_ids(:attack)).sort{|a, b|
        b.effect(:attack) <=> a.effect(:attack)
      }[0, 3]
    end


    def best_defence
      character.inventories.equipped.by_item_id(Item.with_effect_ids(:defence)).sort{|a, b|
        b.effect(:defence) <=> a.effect(:defence)
      }[0, 3]
    end
  
    def effects
      @effects ||= Rails.cache.fetch(effect_cache_key, :expires_in => 15.minutes) do
        [
          {}.tap do |result|
            Effects::Base::BASIC_TYPES.each do |effect|
              result[effect] = inventories.sum{|i| i.effect(effect) }
            end
          end,
          
          [].tap do |result|
            inventories.each do |inventory|
              inventory.effects.each do |effect|
                if Effects::Base::COMPLEX_TYPES.include?(effect.name.to_sym)
                  result << effect
                end
              end
            end
          end
        ]
      end
    end
    
    def effect(name)
      effects[0][name.to_sym]
    end

    protected

    def equipped_amount(inventory)
      placements.values.flatten.count(inventory.id)
    end

    def placements_with_free_slots
      PLACEMENTS.select{|placement| available_capacity(placement) > 0 }
    end

    def placement_capacity(placement)
      case placement
      when :additional
        result = character.character_type.try(:equipment_slots) || Setting.i(:character_equipment_slots)

        if Setting.i(:character_relations_per_equipment_slot) > 0
          result += character.relations.effective_size / Setting.i(:character_relations_per_equipment_slot)
        end

        result
      else
        1
      end
    end

    def equipped_slots(inventory)
      PLACEMENTS.select{|placement| placements[placement].try(:include?, inventory.id) }
    end

    def used_capacity(placement)
      placements[placement].try(:size).to_i
    end

    def effect_cache_key
      "character_#{ character.id }_equipment_effects"
    end

    def clear_effect_cache!
      Rails.cache.delete(effect_cache_key)

      @effects = nil

      true
    end
  end
end
