class AddEffectsToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :effects, :text
    
    Item.reset_column_information
    
    puts "Setting item effects..."
    
    Item.transaction do
      Item.find_each(:batch_size => 100) do |item|
        effects = {}
        
        [:attack, :defence, :health, :energy, :stamina, :hp_restore_rate, :sp_restore_rate, :ep_restore_rate].each do |effect|
          value = item.send(effect)
          
          effects[effect] = {:type => effect, :value => value } if value.to_i != 0
        end
        
        item.effects = effects
        item.save
      end
    end
    
    
    puts "Removing old fields from the database..."
    
    change_table :items do |t|
      t.remove :attack
      t.remove :defence
      t.remove :health
      t.remove :energy
      t.remove :stamina
      t.remove :hp_restore_rate
      t.remove :sp_restore_rate
      t.remove :ep_restore_rate
    end
  end

  def self.down
    change_table :items do |t|
      t.integer :attack,          :default => 0
      t.integer :defence,         :default => 0
      t.integer :health,          :default => 0
      t.integer :energy,          :default => 0
      t.integer :stamina,         :default => 0
      t.integer :hp_restore_rate, :default => 0
      t.integer :sp_restore_rate, :default => 0
      t.integer :ep_restore_rate, :default => 0
    end
    
    remove_column :items, :effects
  end
end
