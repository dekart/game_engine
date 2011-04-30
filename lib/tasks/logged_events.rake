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
    
    def write_to_file(file, scope, batch=100)
      first  = scope.first
      last   = scope.last

      if first and last
        total = scope.count

        puts "Writing #{total} records (from #{first.id} to #{last.id}) to file..."

        i = first.id

        while i < last.id
          events = scope.all(:conditions => {:id => i..i + batch - 1})
          
          puts "Writen records from #{i} to #{events.last.id}"
          
          events.each do |event|
            file.puts event.csv_line
          end

          i += batch
        end

        puts "Done!"
      else
        puts "No records found"
      end
    end
    
    desc "Retrieve event data from db & save it in csv format"
    task :export, [:from, :to] => :environment do |t, args|
      args.with_defaults(:from => 1.week.ago, :to => Time.now)

      puts "Retrieving data from DB..."
      
      from = args.from
      to = args.to
      
      events = LoggedEvent.scoped(
        :conditions => {:export => true, :occurred_at => from..to}
      )
      
      File.open(Rails.root.join('tmp', 'logged_events.csv'), 'w') do |file|
        file.puts "time,character_id,money,gems,health,energy,stamina,experience,artefact,action"
        
        write_to_file(file, events)
      end
      
    end
  end
end
