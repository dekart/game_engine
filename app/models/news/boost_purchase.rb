module News
  class BoostPurchase < Base
    def amount
      data[:amount]
    end

    def boost
      @boost ||= Boost.find(data[:boost_id])
    end
  end
end
