class CreateQuests < ActiveRecord::Migration
  def self.up
    create_table :quests do |t|
      t.integer :level
      
      t.string  :name
      t.string  :description

      t.string  :won_text
      t.string  :lost_text

      t.integer :win_amount
      t.string  :winner_title

      t.integer :ep_cost

      t.integer :experience

      t.integer :money_min
      t.integer :money_max

      t.timestamps
    end
  end

  def self.down
    drop_table :quests
  end
end
