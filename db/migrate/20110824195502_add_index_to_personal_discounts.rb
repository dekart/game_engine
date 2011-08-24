class AddIndexToPersonalDiscounts < ActiveRecord::Migration
  def self.up
    add_index :personal_discounts, [:character_id, :available_till]
  end

  def self.down
    remove_index :personal_discounts, :column => [:character_id, :available_till]
  end
end
