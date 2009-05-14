class AddRequirementsForMissions < ActiveRecord::Migration
  def self.up
    add_column :missions, :requirements, :text

    Mission.all.each do |m|
      m.update_attribute(:requirements, Requirements::Collection.new)
    end
  end

  def self.down
    remove_column :missions, :requirements
  end
end
