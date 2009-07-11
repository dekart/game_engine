class AddHolderToInventory < ActiveRecord::Migration
  def self.up
    add_column :inventories, :holder_id, :integer
    add_column :inventories, :holder_type, :string, :limit => 50

    Inventory.update_all("holder_id = character_id, holder_type = 'Character'", "placement IS NOT NULL")

    add_column :relations, :inventory_effects, :text
    add_column :characters, :relation_effects, :text
  end

  def self.down
    remove_column :inventories, :holder_id
    remove_column :inventories, :holder_type

    remove_column :relations, :inventory_effects
    remove_column :characters, :relation_effects
  end
end
