class AddMaximumNumberOfRewardCollectorsToMonsterTypes < ActiveRecord::Migration
  def self.up
    add_column :monster_types, :maximum_reward_collectors, :integer
  end

  def self.down
    remove_column :monster_types, :maximum_reward_collectors
  end
end
