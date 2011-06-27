class AddPublisherIdToStoryVisits < ActiveRecord::Migration
  def self.up
    change_table :story_visits do |t|
      t.integer :publisher_id
    end
    
    add_index :story_visits, [:character_id, :publisher_id, :reference_id]
  end

  def self.down
    change_table :story_visits do |t|
      t.remove :publisher_id
    end
  end
end
