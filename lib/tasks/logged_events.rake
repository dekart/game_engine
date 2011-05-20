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
              LoggedEvent.create!(JSON.parse(e))
              
              i += 1
              
              puts "Processed #{i} events..." if i % 100 == 0
            end
          end
        rescue Exception => e
          puts "Exception raised: #{ e }"
          puts e.backtrace.join("\n")
          break
        else
          EventLoggingService.trim_event_list(batch_size)
        end
      end

      puts "Done! #{i} events processed"
    end
    

    desc "Retrieve event data from db & save it in csv format"
    task :export, [:from, :to] => :environment do |t, args|
      from = args.from ? Time.parse(args.from) : 1.week.ago
      to = args.to ? Time.parse(args.to) : Time.now
      
      events = LoggedEvent.scoped(:conditions => {:export => true, :occurred_at => from..to})
      
      total = events.count

      puts "Exporting logged events from #{ from.to_s(:short) } to #{ to.to_s(:short) } (#{ total } events)..."
      
      i = 0
      
      File.open(Rails.root.join('tmp', 'logged_events.csv'), 'w') do |file|
        file.puts "time,character_id,money,gems,health,energy,stamina,experience,artefact,action"

        events.find_each do |event|
          file.puts event.csv_line
          
          i += 1
          
          puts "Processed #{i} of #{total} events..." if i % 100 == 0
        end
      end
      
      puts "Done! #{total} events processed"
    end
  end
end
