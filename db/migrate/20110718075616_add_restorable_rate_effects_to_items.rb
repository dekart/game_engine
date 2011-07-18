class AddRestorableRateEffectsToItems < ActiveRecord::Migration
  def self.up
    change_table :items do |t|
      t.integer :hp_restore_rate, :default => 0
      t.integer :sp_restore_rate, :default => 0
      t.integer :ep_restore_rate, :default => 0
    end
  end

  def self.down
    change_table :items do |t|
      t.remove :hp_restore_rate
      t.remove :sp_restore_rate
      t.remove :ep_restore_rate
    end
  end
end
