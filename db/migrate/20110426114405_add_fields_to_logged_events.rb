class AddFieldsToLoggedEvents < ActiveRecord::Migration
  def self.up
    ActiveRecord::Migration.execute 'TRUNCATE TABLE logged_events'
    
    change_table :logged_events do |t|
      t.remove :attacker_damage
      t.remove :victim_damage
      
      t.integer :health, :energy, :stamina
      t.integer :reference_damage
      
      t.boolean :export, :default => false
    end
  end

  def self.down
    remove_column :logged_events, :export
    remove_column :logged_events, :stamina
    remove_column :logged_events, :energy
    remove_column :logged_events, :reference_damage
    remove_column :logged_events, :health
    add_column :logged_events, :victim_damage, :integer
    add_column :logged_events, :attacker_damage, :integer
  end
end
