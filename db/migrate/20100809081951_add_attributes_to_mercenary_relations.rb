class AddAttributesToMercenaryRelations < ActiveRecord::Migration
  def self.up
    change_table :relations do |t|
      t.integer :level, :attack, :defence, :health, :energy, :stamina
    end

    Rake::Task["app:maintenance:assign_attributes_to_mercenaries"].execute
  end

  def self.down
    change_table :relations do |t|
      t.remove :level, :attack, :defence, :health, :energy, :stamina
    end
  end
end
