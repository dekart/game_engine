class AddImageTimestampsToClan < ActiveRecord::Migration
  def self.up
    add_column :clans, :image_updated_at, :datetime 
  end

  def self.down
    remove_column :clans, :image_updated_at
  end
end
