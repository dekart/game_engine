class AddPowerAttackEnabledToMonsterTypes < ActiveRecord::Migration
  def self.up
    add_column :monster_types, :power_attack_enabled, :boolean, :default => true
  end

  def self.down
    remove_column :monster_types, :power_attack_enabled
  end
end
