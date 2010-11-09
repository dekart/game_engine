module Jobs
  class InvitationNotification < Struct.new(:invitation_id)
    def perform
      if invitation = Invitation.find_by_id(invitation_id) and invitation.accepted? and invitation.created_at > 15.minutes.ago
        begin
          Publisher::Invitation.create_notification(invitation)
        rescue Facebooker::Session::TooManyUserActionCalls
          logger.error "[Invitation Notification] User action call limit exceeded"
        rescue Curl::Err::GotNothingError
          logger.error "[Invitation Notification] Facebook did not returned result"
        end
      end
    end
  end
end
