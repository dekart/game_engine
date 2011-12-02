module Jobs
  module Characters
    class UpdateRating
      def perform
        puts "Updating rating values for characters..."
        
        updated_ids = Rating.process_scheduled_updates!
        
        puts "%d characters updated" % updated_ids.size
        
        if !updated_ids.empty? && Setting.b(:total_score_publishing_in_facebook_enabled)
          puts "Scheduling score update in facebook..."
          
          Jobs::Characters::PublishScoreInFacebook.schedule_publishing(updated_ids)
        
          puts "Done!"
        end
      end
    end
  end
end