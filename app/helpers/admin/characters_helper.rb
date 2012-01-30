module Admin::CharactersHelper
  class PaymentStatsPresenter
    def initialize(character)
      @character = character
    end

    def purchases
      @character.vip_money_deposits.purchases
    end

    def total_amount
      @total_amount ||= purchases.sum(:amount)
    end

    def total_transactions
      @total_transactions ||= purchases.count
    end

    def last_payment_at
      @last_payment_at ||= purchases.first(:order => "created_at DESC").try(:created_at)
    end
  end

  def admin_character_payment_stats(character)
    yield PaymentStatsPresenter.new(character)
  end
end
