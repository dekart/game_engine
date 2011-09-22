module Notification
  class ExchangeOfferAccepted < Base
    def exchange_offer
      @exchange_offer ||= ::ExchangeOffer.find(data[:exchange_offer_id])
    end
    
    def exchange
      exchange_offer.exchange
    end
  end
end
