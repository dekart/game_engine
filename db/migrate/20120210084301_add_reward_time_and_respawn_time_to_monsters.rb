class AddRewardTimeAndRespawnTimeToMonsters < ActiveRecord::Migration
  def self.up
    add_column :monster_types, :respawn_time, :integer, :default => 24
    add_column :monster_types, :reward_time,  :integer, :default => 24
  end

  def self.down
    remove_column :monster_types, :respawn_time
    remove_column :monster_types, :reward_time
  end
end
