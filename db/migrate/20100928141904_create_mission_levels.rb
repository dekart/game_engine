class CreateMissionLevels < ActiveRecord::Migration
  def self.up
    create_table :mission_levels do |t|
      t.integer :mission_id
      t.integer :position

      t.integer :win_amount
      t.integer :chance,  :default => 100
      t.integer :energy
      t.integer :experience
      t.integer :money_min
      t.integer :money_max
      t.text    :payouts

      t.timestamps
    end
  end

  def self.down
    drop_table :mission_levels
  end
end
