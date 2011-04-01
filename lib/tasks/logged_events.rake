namespace :app do
  namespace :logged_events do
    desc "Retrieve event data from redis & save it to db"
    task :store => :environment do
      puts "Retrieving data from Redis..."
            
      batch_size = 100

      i = 0
      
      until EventLoggingService.empty_event_list?
        begin
          LoggedEvent.transaction do
            events = EventLoggingService.get_next_batch(batch_size)

            events.each do |e|
              LoggedEvent.create(JSON.parse(e))
              
              i += 1
              
              puts "Processed #{i} events..." if i % 100 == 0
            end
          end
        rescue Exception => exc
          puts "Exception raised: #{exc}"
          break
        else
          EventLoggingService.trim_event_list(batch_size)
        end
      end

      puts "Done! #{i} events processed"
    end
  end
end
