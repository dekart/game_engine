class CreateMissionLevelRanks < ActiveRecord::Migration
  def self.up
    create_table :mission_level_ranks do |t|
      t.integer :character_id
      t.integer :mission_id
      t.integer :level_id

      t.integer :progress,  :default => 0
      t.boolean :completed, :default => false

      t.timestamps
    end

    change_table :ranks do |t|
      t.remove :win_count

      t.integer :progress, :default => 0
    end

    rename_table :ranks, :mission_ranks
  end

  def self.down
    rename_table :mission_ranks, :ranks

    change_table :ranks do |t|
      t.integer :win_count, :default => 0

      t.remove :progress
    end

    drop_table :mission_level_ranks
  end
end
