module Jobs
  module Contests
    class NotifyParticipants
      def perform
        puts "Notifying participants about finished contest..."

        Contest.finished.where(:finish_notification_sent => false).each do |contest|
          contest.send_finish_notification!
        end

        puts "Done!"
      end
    end
  end
end