class AddTextsToContests < ActiveRecord::Migration
  def self.up
    rename_column :contests, :description, :description_when_finished
    
    add_column :contests, :description_when_started, :text
    add_column :contests, :description_before_started, :text
  end

  def self.down
    rename_column :contests, :description_when_finished, :description
    
    remove_column :contests, :description_when_started
    remove_column :contests, :description_before_started
  end
end
