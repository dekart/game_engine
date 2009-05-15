class AddPayoutsToMissions < ActiveRecord::Migration
  def self.up
    add_column :missions, :payouts, :text

    Mission.all.each do |mission|
      mission.update_attribute(:payouts, Payouts::Collection.new)
    end
  end

  def self.down
    remove_column :missions, :payouts
  end
end
