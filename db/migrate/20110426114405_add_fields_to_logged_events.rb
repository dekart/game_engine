class AddFieldsToLoggedEvents < ActiveRecord::Migration
  def self.up
    remove_column :logged_events, :attacker_damage
    remove_column :logged_events, :victim_damage
    add_column :logged_events, :health, :integer
    add_column :logged_events, :reference_damage, :integer
    add_column :logged_events, :energy, :integer
    add_column :logged_events, :stamina, :integer
    add_column :logged_events, :export, :boolean, :default => false
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
