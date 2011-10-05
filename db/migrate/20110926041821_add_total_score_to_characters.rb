class AddTotalScoreToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :total_score, :integer, :default => 0, :null => false
    
    add_index :characters, :total_score
  end

  def self.down
    remove_column :characters, :total_score
  end
end
