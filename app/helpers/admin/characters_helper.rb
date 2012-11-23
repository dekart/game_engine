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

    def free_amount
      @character.vip_money_deposits.sum(:amount) - total_amount
    end

    def total_transactions
      @total_transactions ||= purchases.count
    end

    def last_payment_at
      @last_payment_at ||= purchases.first(:order => "created_at DESC").try(:created_at)
    end
  end

  class SocialStatsPresenter
    def initialize(character)
      @character = character
    end

    def friends
      @character.user.friend_ids.size
    end

    def friends_in_game
      @character.friend_filter.app_users.size
    end

    def referrals
      User.referred_by(@character.user).count
    end
  end

  def admin_character_payment_stats(character)
    yield PaymentStatsPresenter.new(character)
  end

  def admin_character_social_stats(character)
    yield SocialStatsPresenter.new(character)
  end

  def admin_fb_profile_name(character)
    character.user.full_name.present? ? character.user.full_name : "UID #{character.user.facebook_id}"
  end

  def admin_character_name(character)
    character.nickname(true).present? ? character.nickname(true) : "UID #{character.user.facebook_id}"
  end
end
