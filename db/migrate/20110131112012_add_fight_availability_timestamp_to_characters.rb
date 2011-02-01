class AddFightAvailabilityTimestampToCharacters < ActiveRecord::Migration
  def self.up
    change_table :characters do |t|
      t.datetime :fighting_available_at, :default => Time.at(0)
    end
  end

  def self.down
    change_table :characters do |t|
      t.remove :fighting_available_at
    end
  end
end
