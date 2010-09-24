class AddRequirementsToMissionGroups < ActiveRecord::Migration
  def self.up
    change_table :mission_groups do |t|
      t.text :requirements
    end
  end

  def self.down
    change_table :mission_groups do |t|
      t.remove :requirements
    end
  end
end
