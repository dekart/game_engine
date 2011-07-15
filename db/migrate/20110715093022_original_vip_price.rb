class OriginalVipPrice < ActiveRecord::Migration
  def self.up
    add_column :items, :original_vip_price, :integer
  end

  def self.down
    remove_column :items, :original_vip_price
  end
end
