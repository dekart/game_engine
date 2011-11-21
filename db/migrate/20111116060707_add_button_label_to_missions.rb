class AddButtonLabelToMissions < ActiveRecord::Migration
  def self.up
    add_column :missions, :button_label, :string, :default => "", :null => false
  end

  def self.down
    remove_column :missions, :button_label
  end
end
