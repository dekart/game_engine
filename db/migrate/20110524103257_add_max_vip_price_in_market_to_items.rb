class AddMaxVipPriceInMarketToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :max_vip_price_in_market, :integer
    
    Item.transaction do 
      Item.find_each(:conditions => 'vip_price > 0') do |item|
        item.max_vip_price_in_market = item.vip_price
        item.save!
      end
    end
  end

  def self.down
    remove_column :items, :max_vip_price_in_market
  end
end
