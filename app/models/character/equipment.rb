class Character
  class Equipment < ActiveRecord::Base
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
    serialize :inventories, Inventories::Collection

    class << self
      def placement_name(name)
        I18n.t("inventories.placements.names.#{name}", :default => name.to_s.humanize)
      end
    end

    def inventories
      self[:inventories].tap do |inventories|
        inventories.character ||= character
      end
    end

    delegate(:items, :equipped_items, :to => :inventories)

    def main_placements
      MAIN_PLACEMENTS
    end

    def all_placements
      PLACEMENTS
    end

    def placements
      self[:placements] ||= {}
    end

    def inventories_by_placement(placement)
      Array.wrap(placements[placement.to_sym]).collect do |id|
        inventories.find_by_item_id(id)
      end
    end


    def equip!(item, placement)
      Character.transaction do

        previous = equip(item, placement)

        save

        clear_effect_cache!
      end
    end

    def unequip!(item, placement)
      Character.transaction do
        unequip(item, placement)

        save

        clear_effect_cache!
      end
    end

    def auto_equip(item, amount = nil)
      inventory = inventories.find_by_item(item)
      amount ||= inventory.amount_available_for_equipment

      amount.times do
        if placement = (placements_with_free_slots & item.placements).first
          equip(item, placement)
        else
          break
        end
      end

    end

    def auto_equip!(item, amount = nil)
      Character.transaction do
        auto_equip(item, amount)

        save

        clear_effect_cache!
      end
    end

    def auto_unequip(item)
      inventory = inventories.find_by_item(item)
      amount_to_unequip = inventory ? (inventory.equipped - inventory.amount) : equipped_amount(item)

      return if amount_to_unequip <= 0

      amount_to_unequip.times do
        if placement = equipped_slots(item).last
          unequip(item, placement)
        else
          break
        end
      end
    end

    def auto_unequip!(item)
      Character.transaction do
        auto_unequip(item)

        save

        clear_effect_cache!
      end
    end

    def equip_best!(force_unequip = false)
      unequip_all! if force_unequip

      equippables = inventories.equippable

      Character.transaction do
        while free_slots > 0
          equipped = nil

          Effects::Base::BASIC_TYPES.each do |effect|
            candidates = equippables.select{|i| i.equippable? && i.effect(effect) != 0}.sort_by{|i| [i.effect(effect), i.effects.metric]}.reverse

            candidates.each do |inventory|
              if auto_equip(inventory.item, 1)
                equipped = inventory

                break
              end
            end
          end

          break if equipped == nil
        end

        equippables.each do |inventory|
          inventory.item.save if inventory.item.changed?
        end

        save

        clear_effect_cache!
      end
    end

    def unequip_all!
      Character.transaction do
        inventories.each do |inventory|
          inventory.equipped = 0
        end
        self.placements = {}

        save

        clear_effect_cache!
      end
    end

    def free_slots
      PLACEMENTS.sum{|placement| available_capacity(placement) }
    end

    def best_offence
      inventories.equipped_items.where(:id => Item.with_effect_ids(:attack)).sort{|a, b|
        b.effect(:attack) <=> a.effect(:attack)
      }[0, 3]
    end

    def best_defence
      inventories.equipped_items.where(:id => Item.with_effect_ids(:defence)).sort{|a, b|
        b.effect(:defence) <=> a.effect(:defence)
      }[0, 3]
    end


    protected

    def equipped_amount(item)
      placements.values.flatten.count(item.id)
    end

    def placements_with_free_slots
      PLACEMENTS.select{|placement| available_capacity(placement) > 0 }
    end

    def equipped_slots(item)
      PLACEMENTS.select{|placement| placements[placement].try(:include?, item.id) }
    end

  end
end
