class RemoveBookmarkFlagFromUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.remove :show_bookmark
    end
  end

  def self.down
    change_table :users do |t|
      t.boolean  "show_bookmark", :default => true
    end
  end
end
