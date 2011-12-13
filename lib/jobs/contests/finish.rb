module Jobs
  module Contests
    class Finish
      def perform
        puts "Finishing timed out contests..."
        
        Contest.with_state(:visible).find_each(:conditions => ['finished_at <= ?', Time.now]) do |contest|
          contest.finish!
        end
        
        puts "Done!"
      end
    end
  end
end