class CreateSimulations < ActiveRecord::Migration
  def up
    create_table :simulations do |t|
      t.integer :admin_id
      t.integer :user_id
    end
  end

  def down
    drop_table :simulations
  end
end