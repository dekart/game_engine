class CreatePlacements < ActiveRecord::Migration
  def self.up
    create_table :character_equipment do |t|
      t.integer :character_id
      t.text :placements
      t.timestamps
    end

    change_table :characters do |t|
      t.rename :placements, :placements_old
    end

    puts "Updating equipment placements for #{Character.count} characters..."
    
    i = 0

    Character.find_in_batches(:batch_size => 100) do |characters|
      Character.transaction do
        characters.each do |character|
          equipment = Character::Equipment.new(:character => character, :placements => character[:placements_old])
          equipment.save!
          i += 1
          puts "Processed #{i}..." if i % 100 == 0
        end
      end
    end

    puts "Done!"
  end

  def self.down
    change_table :characters do |t|
      t.rename :placements_old, :placements
    end

    drop_table :character_equipment
  end
end
