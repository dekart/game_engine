class Character
  module Inventories
    def give(item, amount = 1)
      amount = amount.to_i

      if inventory = find_by_item(item)
        inventory.amount += amount
      else
        inventory = build(:item => item, :amount => amount)
        inventory.character = proxy_owner
      end

      inventory
    end

    def give!(item, amount = 1)
      inventory = give(item, amount)

      transaction do
        if inventory.save
          Item.update_counters(inventory.item_id, :owned => amount)

          equip(inventory)
        end
      end

      inventory
    end

    def buy!(item, amount = 1)
      effective_amount = amount * item.package_size

      inventory = give(item, effective_amount)

      inventory.charge_money = true

      transaction do
        if inventory.save
          Item.update_counters(inventory.item_id, :owned => effective_amount)

          equip(inventory)

          proxy_owner.news.add(:item_purchase, :item_id => item.id, :amount => effective_amount)
        end
      end

      inventory
    end

    def sell!(item, amount = 1)
      if inventory = find_by_item(item)
        inventory.deposit_money = true

        transaction do
          if inventory.amount > amount
            inventory.amount -= amount
            inventory.save

            Item.update_counters(inventory.item_id, :owned => - amount)

            if inventory.market_items_count > 0 and inventory.market_item.amount > inventory.amount
              inventory.market_item.destroy
            end
          else
            inventory.destroy

            Item.update_counters(inventory.item_id, :owned => - inventory.amount)
          end

          unequip(inventory)
        end

        inventory
      else
        false
      end
    end

    def take!(item, amount = 1)
      if inventory = find_by_item(item)
        transaction do
          if inventory.amount > amount
            inventory.amount -= amount
            inventory.save

            Item.update_counters(inventory.item_id, :owned => - amount)

            if inventory.market_items_count > 0 and inventory.market_item.amount > inventory.amount
              inventory.market_item.destroy
            end
          else
            inventory.destroy

            Item.update_counters(inventory.item_id, :owned => - inventory.amount)
          end

          unequip(inventory)
        end

        inventory
      else
        false
      end
    end

    def transfer!(character, item, amount = 1)
      transaction do
        take!(item, amount)
        character.inventories.give!(item.is_a?(Inventory) ? item.item : item, amount)
      end
    end

    protected

    def find_by_item(item)
      inventory = item.is_a?(Inventory) ? item : find_by_item_id(item.id, :include => :item)

      inventory.try(:character=, proxy_owner)
      
      inventory
    end

    def equip(inventory)
      if Setting.b(:character_auto_equipment)
        proxy_owner.equipment.equip_best!(true)
      else
        proxy_owner.equipment.auto_equip!(inventory)
      end
    end

    def unequip(inventory)
      if Setting.b(:character_auto_equipment)
        proxy_owner.equipment.equip_best!(true)
      else
        proxy_owner.equipment.auto_unequip!(inventory)
      end
    end
  end
end
