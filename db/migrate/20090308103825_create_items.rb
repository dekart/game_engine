class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :level

      t.integer :price

      t.string  :name
      t.string  :description

      t.integer :attack
      t.integer :defence

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
