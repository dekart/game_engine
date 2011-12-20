class Character
  module Clans
    def self.included(base)
      base.class_eval do
        has_one :clan, :through => :clan_member
        has_one :clan_member
        has_many :clan_membership_applications, :extend => ClanMembershipApplicationExtension
      end
    end
    
    module ClanMembershipApplicationExtension
      def declared_to_join?(clan)
        detect{|a| a.clan_id == clan.id}
      end
      
      def apply_to_join!(clan)
        transaction do
          if application = create(:clan => clan)
            clan.creator.notifications.schedule(:clan_application_state,
              :clan_id => clan.id,
              :applicant_id  => application.character_id,
              :status  => "declared"
            )
          end    
        end  
      end
      
    end
  end
end