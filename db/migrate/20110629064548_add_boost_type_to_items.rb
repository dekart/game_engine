class AddBoostTypeToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :boost_type, :string, :limit => 50, :null => false, :default => ""
    Item.update_all("boost_type = 'fight'", :boost => true)
    remove_column :items, :boost
    
    add_column :characters, :active_boosts, :text
  end

  def self.down
    add_column :items, :boost, :boolean
    remove_column :items, :boost_types
    
    remove_column :characters, :active_boosts
  end
end
