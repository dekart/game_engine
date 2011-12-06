module Jobs
  module Monsters
    class Expire
      def perform
        puts "Expiring monsters..."
        
        Monster.with_state(:progress).find_each(:conditions => ['expire_at <= ?', Time.now]) do |monster|
          monster.expire!
        end
        
        puts "Done!"
      end
    end
  end
end