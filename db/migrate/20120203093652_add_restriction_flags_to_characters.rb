class AddRestrictionFlagsToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :restrict_fighting, :boolean, :default => false
    add_column :characters, :restrict_market,   :boolean, :default => false
    add_column :characters, :restrict_talking,  :boolean, :default => false
    
    Character.reset_column_information
    
    remove_index  :characters, :name => :by_level_and_fighting_time_and_exclusion
    add_index     :characters, [:level, :fighting_available_at, :exclude_from_fights, :restrict_fighting], :name => "by_level_and_fighting_time_and_flags"
  end

  def self.down
    remove_column :characters, :restrict_fighting
    remove_column :characters, :restrict_market
    remove_column :characters, :restrict_talking
    
    remove_index  :characters, :name => :by_level_and_fighting_time_and_flags
    add_index     :characters, [:level, :fighting_available_at, :exclude_from_fights], :name => "by_level_and_fighting_time_and_exclusion"
  end
end
