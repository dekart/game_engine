class AddDefaultLevelValueToPropertyTypes < ActiveRecord::Migration
  def self.up
    change_table :property_types do |t|
      t.change :level, :integer, :default => 1
    end
  end

  def self.down
    change_table :property_types do |t|
      t.change :level, :integer, :default => nil
    end
  end
end
