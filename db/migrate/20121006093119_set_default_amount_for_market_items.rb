class SetDefaultAmountForMarketItems < ActiveRecord::Migration
  def up
    change_column :market_items, :amount, :integer, :default => 1
  end

  def down
    change_column :market_items, :amount, :integer, :default => nil
  end
end
