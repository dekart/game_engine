class CreateUpgradeRecipes < ActiveRecord::Migration
  def self.up
    create_table :upgrade_recipes do |t|
      t.integer  :item_id
      t.integer  :result_id
      t.integer  :price

      t.string   :state, :limit => 50, :default => "", :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :upgrade_recipes
  end
end
