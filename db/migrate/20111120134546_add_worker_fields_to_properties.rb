class AddWorkerFieldsToProperties < ActiveRecord::Migration
  def self.up
    change_table :property_types do |t|
      t.integer :workers
      t.string  :worker_names, :null => false, :default => ''
    end
    
    change_table :properties do |t|
      t.integer :workers, :default => 0
      t.string  :worker_friend_ids, :null => false, :default => ''
    end
  end

  def self.down
    change_table :property_types do |t|
      t.remove :workers
      t.remove :worker_names
    end
    
    change_table :properties do |t|
      t.remove :workers
      t.remove :worker_friend_ids
    end
  end
end
