class AddRequirementsToMissionLevels < ActiveRecord::Migration
  def self.up
    change_table :mission_levels do |t|
      t.text :requirements
    end
  end

  def self.down
    change_table :mission_levels do |t|
      t.remove :requirements
    end
  end
end
