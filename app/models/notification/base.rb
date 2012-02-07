module Notification
  class Base < ActiveRecord::Base
    self.table_name = :notifications

    belongs_to :character

    serialize :data

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
    end

    scope :by_type, Proc.new{|type|
      {
        :conditions => {:type => type_to_class_name(type)}
      }
    }

    scope :pending_by_type, Proc.new{|type|
      {
        :conditions => {
          :type   => type_to_class_name(type),
          :state  => "pending"
        }
      }
    }

    class << self
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
  end
end
