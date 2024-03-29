module Notification
  class Base
    TYPES = [
      ContestFinished,
      ExchangeOfferAccepted,
      ExchangeOfferCreated,
      FriendsToInvite,
      HitListed,
      ItemsCollection,
      LevelUp,
      MarketItemSold,
      NewAchievement,
      SendGift,
      NewWallPost
    ]

    cattr_accessor :types

    attr_accessor :character, :data, :state, :type

    class << self
      def inherited(base)
        Notification::Base.types ||= []
        Notification::Base.types << base
      end

      def title
        name.split("::").last.titleize
      end

      def type_to_class_name(type)
        "Notification::#{type.to_s.camelize}"
      end

      def type_to_class(type)
        type_to_class_name(type).constantize
      end

      def class_to_type_name
        name.split("::").last.underscore
      end

      def optional?
        true
      end
    end

    def class_to_type
      self.class.name.split("::").last.underscore.to_sym
    end

    def title
      self.class.title
    end

    def mark_read_manually
      false
    end

    def initialize(character, data_string = "{}")
      self.character = character
      self.type = self.class_to_type

      data = ActiveSupport::JSON.decode(data_string).symbolize_keys

      self.data = data
    end

    def enable
      $redis.srem("disabled_notifications_#{ character.id }", type)

      $redis.hset("notifications_#{ character.id }", type, data.to_json)
    end

    def disable
      $redis.hdel("notifications_#{ character.id }", type)

      $redis.sadd("disabled_notifications_#{ character.id }", type)
    end

    def delete
      $redis.srem("disabled_notifications_#{ character.id }", type)

      $redis.hdel("notifications_#{ character.id }", type)
    end
  end
end
