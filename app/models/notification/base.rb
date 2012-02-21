module Notification
  class Base
    cattr_accessor :types

    attr_accessor :character, :visible
    attr_accessor :data, :visible
    attr_accessor :state, :visible
    attr_accessor :type, :visible

    state_machine :initial => :pending do
      state :displayed
      state :disabled

      event :schedule do
        transition :displayed => :pending
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

      after_transition :on => :schedule, :do => :mark_pending
      after_transition :on => :display_notification, :do => :mark_displayed
      after_transition :on => :disable, :do => :mark_disabled
      after_transition :on => :enable, :do => :mark_displayed
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

      if data_string == "false"
        self.state = "disabled"
        self.data = nil
      else
        data = ActiveSupport::JSON.decode(data_string)
        self.state = data.delete("state")
        self.data = data
      end
    end

    protected

    def mark_pending
      value = self.data ? self.data.dup : {}
      value[:state] = "pending"

      $redis.hset("notifications_#{self.character.id}", self.type, value.to_json)
    end

    def mark_displayed
      value = self.data ? self.data.dup : {}
      value[:state] = "displayed"

      $redis.hset("notifications_#{self.character.id}", self.type, value.to_json)
    end

    def mark_disabled
      $redis.hset("notifications_#{self.character.id}", self.type, "false")
    end
  end
end
