class CreateClans < ActiveRecord::Migration
  def self.up
    create_table :clans do |t|
      t.string  :name,                        :limit => 100
      t.string  :description
      
      t.string  :image_file_name,             :default => "", :null => false
      t.string  :image_file_content,          :limit => 100
      t.integer :image_file_size

      t.timestamps
    end
    
    create_table :clan_members do |t|
      t.integer :character_id
      t.integer :clan_id
      
      t.string  :role
      
      t.timestamps
    end
  end

  def self.down
    drop_table :clans
    drop_table :clan_members
  end
end
