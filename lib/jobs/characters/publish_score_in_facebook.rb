module Jobs
  module Characters
    class PublishScoreInFacebook
      def self.schedule_publishing(ids)
        ids.each do |id|
          $redis.sadd('facebook_score_publishing', id)
        end
      end
      
      def perform
        puts "Publishing character scores in facebook..."
        
        i = 0
        
        while id = $redis.spop('facebook_score_publishing')
          puts id.inspect
          
          Character.find(id).publish_total_score_in_facebook
          
          i += 1
        end
        
        puts "Done! %d scores published" % i
      end
    end
  end
end