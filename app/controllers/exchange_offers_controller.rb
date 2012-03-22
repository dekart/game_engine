class ExchangeOffersController < ApplicationController
  def create
    @exchange_offer = current_character.exchange_offers.build(params[:exchange_offer])
    @exchange = @exchange_offer.exchange
    
    if @exchange_offer.save
      redirect_to exchange_path(@exchange_offer.exchange.key)
    else
      render 'exchanges/show'
    end
  end
  
  def destroy
    @exchange_offer = current_character.exchange_offers.find(params[:id])
    
    @exchange_offer.destroy
  end
  
  def accept
    @exchange_offer = ExchangeOffer.find(params[:id])
    @exchange = current_character.exchanges.find(@exchange_offer.exchange)
    
    @transacted = @exchange.transact(@exchange_offer)
  end
end
