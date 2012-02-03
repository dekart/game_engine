class AddExcludeFromFightsToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :exclude_from_fights, :boolean, :default => false
    
    Character.reset_column_information
    
    remove_index  :characters, :name => :by_level_and_fighting_time
    add_index     :characters, [:level, :fighting_available_at, :exclude_from_fights], :name => "by_level_and_fighting_time_and_exclusion"
  end

  def self.down
    remove_column :characters, :exclude_from_fights
    
    remove_index  :characters, :name => :by_level_and_fighting_time_and_exclusion
    add_index     :characters, [:level, :fighting_available_at], :name => "by_level_and_fighting_time"
  end
end
