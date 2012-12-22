class AddExcludedFromFightsAtToCharacters < ActiveRecord::Migration
  def up
    change_table :characters do |t|
      t.datetime :excluded_from_fights_at, :null => false, :default => Time.at(0)
    end
  end

  def down
    change_table :characters do |t|
      t.remove :excluded_from_fights_at
    end
  end
end
