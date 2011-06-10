class RemoveUnusedColumnsFromMissions < ActiveRecord::Migration
  def self.up
    change_table :missions do |t|
      t.remove :win_amount
      t.remove :success_chance
      t.remove :ep_cost
      t.remove :experience
      t.remove :money_min
      t.remove :money_max
    end
  end

  def self.down
  end
end
