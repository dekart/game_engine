class Character
  module Exchanges
    def self.included(base)
      base.class_eval do
        has_many :exchanges,
          :dependent  => :destroy,
          :extend   => ExchangeAssociationExtension
          
        has_many :exchange_offers,
          :dependent  => :delete_all,
          :extend   => ExchangeOffersAssociationExtension
      end
    end
    
   module ExchangeAssociationExtension 
     def accept!(exchange_offer)
       exchange_offer.exchange.transact!(exchange_offer) if exchange_offer.exchange.character == proxy_owner
     end
     
     def exchange_by(item)
       proxy_owner.exchanges.with_state(:created).first(:conditions => {:item_id => item})
     end
     
     def in_exchange?(item)
       proxy_owner.exchanges.with_state(:created).exists?(:item_id => item)
     end
   end
   
   module ExchangeOffersAssociationExtension
     def exchanges
       exchange_ids = proxy_owner.exchange_offers.all(:select => :exchange_id).map{|e| e.exchange_id}
       
       Exchange.scoped(:conditions => {:id => exchange_ids})
     end 
   end
  end
end