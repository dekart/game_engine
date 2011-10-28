class CreatePlacements < ActiveRecord::Migration
  def self.up
    create_table :character_equipment do |t|
      t.text :placements, :limit => 65535
      t.timestamps
    end

    add_column :characters, :equipment_id, :integer

    puts "Updating equipment placements for #{Character.count} requests..."
    i = 0

    Character.find_in_batches(:batch_size => 100) do |characters|
      Character.transaction do
        characters.each do |character|
          character.create_equipment(:placements => character[:placements])
          i += 1
          puts "Processed #{i}..." if i % 100 == 0
        end
      end
    end

    change_table :characters do |t|
      t.rename :placements, :placements_old
    end

  end

  def self.down
    change_table :characters do |t|
      t.remove :equipment_id
      t.rename :placements_old, :placements
    end

    drop_table :character_equipment
  end
end
