class AddTotalScoreToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :total_score, :integer, :default => 0, :null => false
    
    puts "Updating characters total score..."
    
    Character.transaction do
      Character.find_each(:batch_size => 100) do |character|
        character.update_total_score!
      end
    end
    
    add_index :characters, :total_score
  end

  def self.down
    remove_column :characters, :total_score
  end
end
