class Character
  module EquipmentExtension

    def self.included(base)
      base.class_eval do

        has_one :equipment
          :dependent  => :destroy,
          :extend     => EquipmentAssociationExtension,
          :inverse_of => :character

        after_validation_on_create :build_equipment

        delegate(:placements, :to => :equipment)

      end
    end

    module EquipmentAssociationExtension

      def effects
        @effects ||= Rails.cache.fetch(effect_cache_key, :expires_in => 15.minutes) do
          {}.tap do |effects|
            Item::EFFECTS.each do |effect|
              effects[effect] = inventories.sum{|i| i.send(effect) }
            end
          end
        end
        @effects
      end

      def effect(name)
        effects[name.to_sym]
      end

      def effect_cache_key
        "character_#{ proxy_owner.id }_equipment_effects"
      end

      def clear_effect_cache!
        Rails.cache.delete(effect_cache_key)

        @effects = nil

        true
      end
    end
  end
end