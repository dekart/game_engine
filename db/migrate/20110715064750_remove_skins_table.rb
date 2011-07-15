class RemoveSkinsTable < ActiveRecord::Migration
  def self.up
    drop_table :skins
  end

  def self.down
    create_table "skins" do |t|
      t.string   "name",       :limit => 100, :default => "", :null => false
      t.text     "content"
      t.string   "state",      :limit => 50,  :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
