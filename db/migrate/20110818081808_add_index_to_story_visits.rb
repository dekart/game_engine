class AddIndexToStoryVisits < ActiveRecord::Migration
  def self.up
    add_index :story_visits, [:character_id, :publisher_id, :reference_id], :name => :index_on_character_publisher_reference
  end

  def self.down
    remove_index :story_visits, :name => :index_on_character_publisher_reference
  end
end
