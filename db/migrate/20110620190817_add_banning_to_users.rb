class AddBanningToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :banned
      t.string  :ban_reason, :default => '', :limit => 100, :null => false
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :banned
      t.remove :ban_reason
    end
  end
end
