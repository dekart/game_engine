class Character
  module EquipmentExtension

    def self.included(base)
      base.class_eval do

        has_one :equipment,
          :dependent  => :destroy,
          :inverse_of => :character

        after_validation :build_equipment, :on => :create

        delegate(:placements, :inventories, :to => :equipment)
        delegate(:items, :equipped_items, :to => :inventories)

      end
    end
  end
end