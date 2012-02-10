class AddPrivateToWallPosts < ActiveRecord::Migration
  def self.up
    change_table :wall_posts do |t|
      t.boolean :private, :default => 0, :null => false
    end
  end

  def self.down
    change_table :wall_posts do |t|
      t.remove :private
    end
  end
end