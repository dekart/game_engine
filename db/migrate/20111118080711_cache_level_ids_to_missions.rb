class CacheLevelIdsToMissions < ActiveRecord::Migration
  def self.up
    change_table :missions do |t|
      t.string :level_ids_cache, :null => false, :default => ''
    end
  end

  def self.down
    change_table :missions do |t|
      t.remove :level_ids_cache
    end
  end
end
