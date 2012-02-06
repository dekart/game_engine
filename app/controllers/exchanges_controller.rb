class ExchangesController < ApplicationController
  def show
    @exchange = Exchange.find(params[:id])
    
    redirect_from_iframe(inventories_path(:canvas => true)) if @exchange.key != params[:id]
    
    @exchange_offer = @exchange.exchange_offers.build if current_character != @exchange.character
  end
  
  def index
    @my_exchanges = current_character.exchanges.with_state(:created)
    
    @participant_exchanges = current_character.exchange_offers.exchanges.with_state(:created)
  end
  
  def new
    @inventory = current_character.inventories.find(params[:inventory_id])
    
    @exchange = Exchange.new(:item_id => @inventory.item.id)
  end
  
  def create
    @exchange = current_character.exchanges.build(params[:exchange])
    
    if @exchange.save
      render :create, :layout => "ajax"
    else
      render :new, :layout => "ajax"
    end
  end
  
  def destroy
    @exchange = current_character.exchanges.find(params[:id])
    
    @exchange.destroy
    
    redirect_from_iframe(exchanges_path(:canvas => true))
  end
end