class CreateCharacters < ActiveRecord::Migration
  def self.up
    create_table :characters do |t|
      t.integer :user_id

      t.string  :name

      t.integer :money,       :default => 100

      t.integer :level,       :default => 1
      t.integer :experience,  :default => 0
      t.integer :points,      :default => 0

      t.integer :attack,      :default => 1
      t.integer :defence,     :default => 1

      t.integer :hp,          :default => 0
      t.integer :health,      :default => 100

      t.integer :ep,          :default => 0
      t.integer :energy,      :default => 10

      t.datetime :hp_refilled_at
      t.datetime :ep_refilled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :characters
  end
end
