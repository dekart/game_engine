class AddEffectsToMonsterTypes < ActiveRecord::Migration
  def self.up
    add_column :monster_types, :effects, :text
    
    MonsterType.reset_column_information
    
    puts "Setting item effects..."
    
    MonsterType.transaction do
      MonsterType.find_each(:batch_size => 100) do |monster_type|
        effects = {}
        
        [:attack, :defence].each do |effect|
          value = monster_type.send(effect)
          
          effects[effect] = {:type => effect, :value => value } if value.to_i != 0
        end
        
        monster_type.effects = effects
        monster_type.save
      end
    end
    
    
    puts "Removing old fields from the database..."
    
    change_table :monster_types do |t|
      t.remove :attack
      t.remove :defence
    end
  end

  def self.down
    change_table :monster_types do |t|
      t.integer :attack,          :default => 0
      t.integer :defence,         :default => 0
    end
    
    remove_column :monster_types, :effects
  end
end
