class AddEventsToMissionsAndMonsters < ActiveRecord::Migration
  def self.up
    %w{mission_groups missions mission_levels monster_types}.each do |table|
      change_table(table) do |t|
        t.text :events
      end
    end
  end

  def self.down
    %w{mission_groups missions mission_levels monster_types}.each do |table|
      change_table(table) do |t|
        t.remove :events
      end
    end
  end
end
