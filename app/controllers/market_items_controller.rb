class MarketItemsController < ApplicationController
  def index
    @items = MarketItem.paginate(:page => params[:page])
  end

  def new
    @inventory = current_character.inventories.find(params[:inventory_id])
    @item = @inventory.build_market_item
  end

  def create
    @inventory = current_character.inventories.find(params[:market_item].delete(:inventory_id))

    @item = @inventory.build_market_item(params[:market_item])

    render :new unless @item.save
  end

  def buy
    @item = MarketItem.find(params[:id])

    @item.buy!(current_character)
  end

  def destroy
    @item = current_character.market_items.find(params[:id])

    @item.destroy
  end
end
