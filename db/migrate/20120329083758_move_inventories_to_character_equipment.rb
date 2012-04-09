class MoveInventoriesToCharacterEquipment < ActiveRecord::Migration
  def up
    # changing db structure
    add_column :character_equipment, :inventories, :text
    Character::Equipment.reset_column_information
    Character::Equipment::Inventories::Inventory
    
    rename_column :market_items, :inventory_id, :item_id
    MarketItem.reset_column_information
    
    
    # fixing data
    Character.has_many :old_inventories, :class_name => 'Inventory'
    
    puts "Moving inventories for #{Character.count} characters..."
    i = 0
    
    Character.find_in_batches(:batch_size => 100) do |characters|
      Character.transaction do
        characters.each do |character|
          equipment = character.equipment
          
          equipment.inventories = Character::Equipment::Inventories::Collection.new(character, 
            character.old_inventories.collect{|record|
              Character::Equipment::Inventories::Inventory.new(
                :item_id  => record.item_id, 
                :amount   => record.amount, 
                :equipped => record.equipped
              )
            }
          )
          
          # item ids in placements
          equipment.placements.each do |key, values|
            equipment.placements[key] = values.map{|id| Inventory.find_by_id(id).try(:item_id) }.compact
          end
          
          equipment.save!
          
          # deactivate boosts
          character.active_boosts = {}
          character.save!
          
          i += 1
          puts "Processed #{i}..." if i % 100 == 0
        end
      end
    end
    
    
    puts "Changing #{MarketItem.count} market items..."
    i = 0
    
    MarketItem.find_in_batches(:batch_size => 100) do |market_items|
      MarketItem.transaction do
        market_items.each do |market_item|
          market_item.item = Inventory.find_by_id(market_item.item_id).try(:item)
          
          market_item.save!
          
          i += 1
          puts "Processed #{i}..." if i % 100 == 0
        end
      end
    end

    puts "Done!"
  end

  def down
    remove_column :character_equipment, :inventories
    rename_column :market_items, :item_id, :inventory_id
  end
end
