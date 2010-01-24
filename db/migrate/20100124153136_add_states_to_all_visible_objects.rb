class AddStatesToAllVisibleObjects < ActiveRecord::Migration
  TABLES = %w{bosses item_groups items mission_groups missions property_types}

  def self.up
    TABLES.each do |t|
      add_column t, :state, :string, :limit => 30

      t.classify.constantize.update_all "state = 'visible'"
    end
  end

  def self.down
    TABLES.each do |t|
      remove_column t, :state
    end
  end
end
