namespace :app do
  namespace :logged_events do
    desc "Retrieve event data from redis & save it to db"
    task :store_to_db => :environment do
      puts "Retrieving data from Redis..."
      
      batch_size = 100

      until EventLoggingService.empty_event_list?
        begin
          LoggedEvent.transaction do
            events = EventLoggingService.get_next_batch(batch_size)

            events.each do |e|
              #puts "Storing event: #{e}"
              LoggedEvent.create(JSON.parse(e))
            end
          end
        rescue Exception => exc
          puts "Exception raised: #{exc}"
          break
        else
          EventLoggingService.trim_event_list(batch_size)
        end
      end

      puts "Done"
    end
  end
end
