class Character
  module Clans
    def self.included(base)
      base.class_eval do
        has_one :clan, :through => :clan_member
        has_one :clan_member
        has_many :clan_membership_applications, :extend => ClanMembershipApplicationExtension
        has_many :clan_membership_invitations, :extend => ClanMembershipInvitationExtension
      end
    end
    
    module ClanMembershipApplicationExtension
      def asked_to_join?(clan)
        find_by_clan_id(clan.id)
      end
    end
    
    module ClanMembershipInvitationExtension
      def invitation_to_join(clan)
        find_by_clan_id(clan.id)
      end
    end
  end
end