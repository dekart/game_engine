class AddIncomeByLevelToPropertyTypes < ActiveRecord::Migration
  def self.up
    add_column :property_types, :income_by_level, :integer, :default => 0
  end

  def self.down
    remove_column :property_types, :income_by_level
  end
end
