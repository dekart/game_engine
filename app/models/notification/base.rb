module Notification
  class Base
    cattr_accessor :types

    attr_accessor :character, :data, :state, :type

    state_machine :initial => :pending do
      state :displayed
      state :disabled

      event :schedule do
        transition any => :pending
      end

      event :display_notification do
        transition any => :displayed
      end

      event :disable do
        transition any => :disabled
      end

      event :enable do
        transition :disabled => :displayed
      end

      after_transition :on => :schedule, :do => :update_data
      after_transition :on => :display_notification, :do => :update_data
      after_transition :on => :disable, :do => :update_data
      after_transition :on => :enable, :do => :update_data
    end

    class << self
      def inherited(base)
        Notification::Base.types ||= []
        Notification::Base.types << base
      end

      def type_to_class_name(type)
        "Notification::#{type.to_s.camelize}"
      end

      def type_to_class(type)
        type_to_class_name(type).constantize
      end
    end

    def class_to_type
      self.class.name.split("::").last.underscore.to_sym
    end

    def title
      self.class.name.split("::").last.titleize
    end

    def optional?
      true
    end

    def initialize(character, data_string = "{}")
      self.character = character
      self.type = self.class_to_type

      data = ActiveSupport::JSON.decode(data_string).symbolize_keys

      self.state = data.delete(:state) if data[:state]
      self.data = data
    end

    def update_data
      data[:state] = state

      $redis.hset("notifications_#{ character.id }", type, data.to_json)
    end
  end
end
