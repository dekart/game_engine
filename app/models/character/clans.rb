class Character
  module Clans
    def self.included(base)
      base.class_eval do
        has_one :clan,:through => :clan_member
        has_one :clan_member
        has_one :clan_membership_application
      end
    end
    
    def member_of?(clan)
      self.clan == clan
    end
    
    def sent_application_join_to?(clan)
      self.clan_membership_application.try(:clan) == clan
    end
  end
end