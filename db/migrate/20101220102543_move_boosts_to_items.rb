class MoveBoostsToItems < ActiveRecord::Migration
  def self.up
    change_table :items do |t|
      t.boolean :boost
    end
  end

  def self.down
    change_table :items do |t|
      t.remove :boost
    end
  end
end
