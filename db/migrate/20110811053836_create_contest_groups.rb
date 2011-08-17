class CreateContestGroups < ActiveRecord::Migration
  def self.up
    create_table :contest_groups do |t|
      t.references :contest
      t.integer :max_character_level
      t.text  :payouts
      
      t.timestamps
    end
    
    rename_table :character_contests, :character_contest_groups
    add_column :character_contest_groups, :contest_group_id, :integer
    
    puts "Create default contest groups for current contests"
    Contest.all.each do |contest|
      contest_group = contest.contest_groups.create!
      
      puts "Migrate data for contest #{contest.id}"
      CharacterContestGroup.update_all("contest_group_id = #{contest_group.id}", "contest_id = #{contest.id}")
    end
    
    change_column :character_contest_groups, :contest_group_id, :integer, :null => false
    
    remove_column :character_contest_groups, :contest_id
  end

  def self.down
    remove_table :contest_groups
    
    rename_table :character_contest_groups, :character_contests
    
    add_column :character_contests, :contest_id, :integer
    
    remove_column :character_contests, :contest_group_id
  end
end
