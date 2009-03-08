class CreateCharacters < ActiveRecord::Migration
  def self.up
    create_table :characters do |t|
      t.integer :user_id

      t.string  :name

      t.integer :money,       :default => 1000

      t.integer :level,       :default => 1
      t.integer :experience,  :default => 0

      t.integer :attack,      :default => 1
      t.integer :defence,     :default => 1

      t.integer :hp,          :default => 100
      t.integer :health,      :default => 100

      t.integer :ep,          :default => 10
      t.integer :energy,      :default => 10

      t.timestamps
    end
  end

  def self.down
    drop_table :characters
  end
end
