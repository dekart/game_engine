module Jobs
  class AssignmentNotification < Struct.new(:session, :assignment_id)
    def perform
      if assignment = Assignment.find_by_id(assignment_id)
        begin
          Publisher::Assignment.deliver_notification(session.user, assignment)
        rescue Facebooker::Session::TooManyUserActionCalls
          logger.error "[Assignment Notification] User action call limit exceeded"
        rescue Curl::Err::GotNothingError
          logger.error "[Assignment Notification] Facebook did not returned result"
        end
      end
    end
  end
end