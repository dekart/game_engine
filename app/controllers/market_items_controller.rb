class MarketItemsController < ApplicationController
  def index
    @market_items = MarketItem.paginate(:page => params[:page])
  end

  def new
    @item = current_character.inventories.items.find(params[:item_id])
    
    @market_item = current_character.market_items.build(:item_id => @item.id)
  end

  def create
    @item = current_character.inventories.items.find(params[:market_item].delete(:item_id))

    @market_item = current_character.market_items.build(params[:market_item].merge(:item_id => @item.id))

    render :new unless @market_item.save
  end

  def buy
    @market_item = MarketItem.find(params[:id])

    @market_item.buy!(current_character)
  end

  def destroy
    @market_item = current_character.market_items.find(params[:id])

    @market_item.destroy
  end
end
