class MovePlacementsToCharacter < ActiveRecord::Migration
  def self.up
    change_table :characters do |t|
      t.text :placements, :limit => 65535
    end

    change_table :inventories do |t|
      t.remove :placement
      t.remove :use_in_fight
      
      t.integer :equipped, :default => 0
    end
  end

  def self.down
    change_table :characters do |t|
      t.remove :placements
    end

    change_table :inventories do |t|
      t.string :placement
    end
  end
end
