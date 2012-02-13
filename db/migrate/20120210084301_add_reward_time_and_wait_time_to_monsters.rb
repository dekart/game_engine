class AddRewardTimeAndWaitTimeToMonsters < ActiveRecord::Migration
  def self.up
    add_column :monster_types, :wait_time,   :integer, :default => 24
    add_column :monster_types, :reward_time, :integer, :default => 24
  end

  def self.down
    add_column :monster_types, :wait_time
    add_column :monster_types, :reward_time
  end
end
