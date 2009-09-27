class Character
  module Inventories
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

      calculate_used_in_fight! if inventory.save

      inventory
    end

    def buy!(item, amount = 1)
      inventory = give(item, amount)

      inventory.charge_money = true

      calculate_used_in_fight! if inventory.save

      inventory
    end

    def sell!(item, amount = 1)
      if inventory = find_by_item_id(item.id)
        inventory.deposit_money = true

        if inventory.amount > amount
          inventory.amount -= amount
          inventory.save
        else
          inventory.destroy
        end

        calculate_used_in_fight!

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
        else
          inventory.destroy
        end

        calculate_used_in_fight!

        inventory
      else
        false
      end
    end

    def calculate_used_in_fight!
      transaction do
        proxy_owner.inventories.update_all "use_in_fight = 0"

        ItemGroup.all.each do |group|
          items_to_use = proxy_owner.relations.size + 1

          proxy_owner.inventories.by_item_group(group).all(:conditions => "attack + defence > 0", :order => "attack + defence DESC").each do |inventory|
            inventory.update_attribute(:use_in_fight,
              inventory.amount <= items_to_use ? inventory.amount : items_to_use
            )
            
            items_to_use -= inventory.amount

            break if items_to_use <= 0
          end
        end
      end
    end

    def best_offence
      returning result = [] do
        ItemGroup.all.each do |group|
          result << proxy_owner.inventories.by_item_group(group).first(
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
          result << proxy_owner.inventories.by_item_group(group).first(
            :conditions => "defence > 0",
            :order      => "defence DESC"
          )
        end

        result.compact!
      end
    end
  end
end