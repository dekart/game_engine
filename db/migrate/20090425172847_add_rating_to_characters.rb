class AddRatingToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :rating, :integer, :default => 0

    Character.find(:all).each do |character|
      character.send(:recalculate_rating)
      character.save
    end
  end

  def self.down
    remove_column :characters, :rating
  end
end
