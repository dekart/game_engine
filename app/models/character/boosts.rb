class Character
  module Boosts
    def amounts_by_type
      amounts = []
      proxy_owner.purchased_boosts.count(:group => "boost_id").each do |boost_id, count|
        amounts << {:boost => Boost.find(boost_id), :amount => count}
      end

      amounts
    end

    def enough_money_for(boost, amount)
      return (boost.basic_price * amount <= proxy_owner.basic_money) &&
             (boost.vip_price * amount <= proxy_owner.vip_money) 
    end

    def buy!(boost, amount)
      transaction do
        amount.times.each do
          proxy_owner.purchased_boosts.create(:boost => boost)
        end

        proxy_owner.charge!(boost.basic_price * amount, boost.vip_price * amount)
      end
    end
  end
end
