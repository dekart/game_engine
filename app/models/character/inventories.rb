class Character
  module Inventories
    def available_for_equipment
      self.all.select{|i|
        i.amount_available_for_equipment > 0
      }
    end

    def give(item, amount = 1)
      if inventory = find_by_item_id(item.id)
        inventory.amount += amount
      else
        inventory = build(:item => item, :amount => amount)
      end

      inventory
    end

    def give!(item, amount = 1)
      inventory = give(item, amount)

      if inventory.save
        Item.update_counters(item.id, :owned => amount)
        
        proxy_owner.equipment.auto_equip!(inventory)
      end

      inventory
    end

    def buy!(item, amount = 1)
      inventory = give(item, amount)

      inventory.charge_money = true

      if inventory.save
        Item.update_counters(item.id, :owned => amount)

        proxy_owner.equipment.auto_equip!(inventory)
      end

      inventory
    end

    def sell!(item, amount = 1)
      if inventory = find_by_item_id(item.id)
        inventory.deposit_money = true

        if inventory.amount > amount
          inventory.amount -= amount
          inventory.save

          Item.update_counters(item.id, :owned => - amount)
        else
          inventory.destroy

          Item.update_counters(item.id, :owned => - inventory.amount)
        end

        proxy_owner.equipment.auto_unequip!(inventory)

        inventory
      else
        false
      end
    end

    def take!(item, amount = 1)
      if inventory = find_by_item_id(item.id)
        if inventory.amount > amount
          inventory.amount -= amount
          inventory.save

          Item.update_counters(item.id, :owned => - amount)
        else
          inventory.destroy

          Item.update_counters(item.id, :owned => - inventory.amount)
        end

        proxy_owner.equipment.auto_unequip!(inventory)

        inventory
      else
        false
      end
    end

    def best_offence
      returning result = [] do
        ItemGroup.all.each do |group|
          result << proxy_owner.inventories.by_item_group(group).equipped.first(
            :conditions => "attack > 0",
            :order      => "attack DESC"
          )
        end

        result.compact!
      end
    end

    def best_defence
      returning result = [] do
        ItemGroup.all.each do |group|
          result << proxy_owner.inventories.by_item_group(group).equipped.first(
            :conditions => "defence > 0",
            :order      => "defence DESC"
          )
        end

        result.compact!
      end
    end
  end
end