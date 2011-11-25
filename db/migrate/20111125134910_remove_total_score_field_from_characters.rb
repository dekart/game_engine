class RemoveTotalScoreFieldFromCharacters < ActiveRecord::Migration
  def self.up
    change_table :characters do |t|
      t.remove :total_score
    end
  end

  def self.down
    change_table :characters do |t|
      t.integer  "total_score",              :limit => 8,          :default => 0,                     :null => false
    end
  end
end
