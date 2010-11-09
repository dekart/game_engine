module Jobs
  class AssignmentNotification < Struct.new(:assignment_id)
    def perform
      if assignment = Assignment.find_by_id(assignment_id) and assignment.created_at > 15.minutes.ago
        begin
          Publisher::Assignment.create_notification(assignment)
        rescue Facebooker::Session::TooManyUserActionCalls
          logger.error "[Assignment Notification] User action call limit exceeded"
        rescue Curl::Err::GotNothingError
          logger.error "[Assignment Notification] Facebook did not returned result"
        end
      end
    end
  end
end
