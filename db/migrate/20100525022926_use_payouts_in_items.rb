class UsePayoutsInItems < ActiveRecord::Migration
  def self.up
    change_table :items do |t|
      t.text :payouts
    end
  end

  def self.down
  end
end
