class AddPositionToMissionGroups < ActiveRecord::Migration
  def self.up
    change_table :mission_groups do |t|
      t.integer :position
    end

    Rake::Task["app:maintenance:add_positions_to_mission_groups"].execute
  end

  def self.down
    change_table :mission_groups do |t|
      t.remove :position
    end
  end
end
