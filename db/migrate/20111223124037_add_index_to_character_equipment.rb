class AddIndexToCharacterEquipment < ActiveRecord::Migration
  def self.up
    add_index :character_equipment, :character_id

    add_index :achievements, :character_id

    add_index :contest_groups, :contest_id

    add_index :credit_orders, :facebook_id
  end

  def self.down
    remove_index :character_equipment, :character_id

    remove_index :achievements, :character_id

    remove_index :contest_groups, :contest_id

    remove_index :credit_orders, :facebook_id
  end
end
