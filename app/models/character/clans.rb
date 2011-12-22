class Character
  module Clans
    def self.included(base)
      base.class_eval do
        has_one :clan, :through => :clan_member
        has_one :clan_member
        has_many :clan_membership_applications, :extend => ClanMembershipApplicationExtension
        has_many :clan_membership_invitations, :extend => ClanMembershipInvitatioExtension
      end
    end
    
    module ClanMembershipApplicationExtension
      def asked_to_join?(clan)
        detect{|a| a.clan_id == clan.id}
      end
      
      def create_application!(clan)
        transaction do
          if application = create(:clan => clan)
            clan.creator.notifications.schedule(:clan_application_state,
              :clan_id => clan.id,
              :applicant_id  => application.character_id,
              :status  => "asked"
            )
          end    
        end  
      end
    end
    
    module ClanMembershipInvitatioExtension
      def invitation_to_join(clan)
        detect{|i| i.clan_id == clan.id}
      end
    end
  end
end