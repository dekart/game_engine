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

    def give!(boost, amount = 1)
      transaction do
        amount.times.each do
          proxy_owner.purchased_boosts.create(:boost => boost)
        end
      end
    end

    def buy!(boost, amount = 1)
      transaction do
        give!(boost, amount)

        proxy_owner.charge!(boost.basic_price * amount, boost.vip_price * amount)

        proxy_owner.news.add(:boost_purchase, :amount => amount, :boost_id => boost.id)
      end
    end

    def take!(boost, amount = 1)
      transaction do
        boosts = all(:conditions => {:boost_id => boost.id}, :limit => amount)

        boosts.each do |boost|
          boost.delete
        end
      end
    end

    def best_attacking
      best_boost_type = nil
      best_attack = 0

      amounts_by_type.each do |b|
        if b[:boost].attack > best_attack
          best_boost_type = b[:boost]
          best_attack = b[:boost].attack
        end
      end

      if best_boost_type
        return proxy_owner.purchased_boosts.find(:first, :conditions => ["boost_id = ?", best_boost_type.id])
      else
        return nil
      end
    end

    def best_defending
      best_boost_type = nil
      best_defence = 0

      amounts_by_type.each do |b|
        if b[:boost].defence > best_defence
          best_boost_type = b[:boost]
          best_defence = b[:boost].defence
        end
      end

      if best_boost_type
        return proxy_owner.purchased_boosts.find(:first, :conditions => ["boost_id = ?", best_boost_type.id])
      else
        return nil
      end
    end
  end
end
