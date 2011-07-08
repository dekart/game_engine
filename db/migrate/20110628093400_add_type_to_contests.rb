class AddTypeToContests < ActiveRecord::Migration
  def self.up
    add_column :contests, :points_type, :string, :default => ""
    
    Contest.all.each do |contest|
      contest.update_attribute(:points_type, Contest::POINTS_TYPES.first.to_s)
    end
  end

  def self.down
    remove_column :contests, :points_type
  end
end
