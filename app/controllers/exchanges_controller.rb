class ExchangesController < ApplicationController
  def show
    @exchange = Exchange.find(params[:id])
    
    redirect_to(inventories_path) if @exchange.key != params[:id]
    
    @exchange_offer = @exchange.exchange_offers.build if current_character != @exchange.character
  end
  
  def index
    @my_exchanges = current_character.exchanges.with_state(:created)
    
    @participant_exchanges = current_character.exchange_offers.exchanges.with_state(:created)
  end
  
  def new
    @item = Item.find(params[:item_id])
    
    @exchange = current_character.exchanges.new(:item_id => @item.id)
  end
  
  def create
    @exchange = current_character.exchanges.build(params[:exchange])
    
    render :new unless @exchange.save
  end
  
  def destroy
    @exchange = current_character.exchanges.find(params[:id])
    
    @exchange.destroy
    
    redirect_to exchanges_path
  end
end