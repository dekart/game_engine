class Character
  class Equipment < ActiveRecord::Base

    MAIN_PLACEMENTS = [:left_hand, :right_hand, :head, :body, :legs]
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
      elsif MAIN_PLACEMENTS.include?(placement) # Main placements can be replaced
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

          Item::EFFECTS.each do |effect|
            candidates = equippables.select{|i| i.equippable? and i.send(effect) != 0}

            if inventory = candidates.max_by{|i| [i.send(effect), i.effects.values.sum]} and auto_equip(inventory, 1)
              equipped = inventory
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
      inventories.select{|i| i.attack > 0 }.sort{|a, b| b.attack <=> a.attack }[0..2]
    end


    def best_defence
      inventories.select{|i| i.defence > 0 }.sort{|a, b| b.defence <=> a.defence }[0..2]
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

        result += character.relations.effective_size / Setting.i(:character_relations_per_equipment_slot)
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

    def clear_effect_cache!
      character.equipment.clear_effect_cache!
    end
  end
end
