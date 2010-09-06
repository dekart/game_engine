class CreateCharacterTitles < ActiveRecord::Migration
  def self.up
    create_table :character_titles do |t|
      t.integer :character_id
      t.integer :title_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :character_titles
  end
end
