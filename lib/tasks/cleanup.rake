namespace :app do
  desc "Cleanup old data"
  task :cleanup => %w{app:cleanup:fights app:cleanup:bank_operations app:cleanup:news app:cleanup:app_requests app:cleanup:events app:cleanup:tracking_requests app:cleanup:monster_chats}

  namespace :cleanup do
    def remove_data(scope, batch = 100)
      first  = scope.first
      last   = scope.last

      if first and last
        total = scope.count

        puts "Deleting #{total} records (from #{first.id} to #{last.id})..."

        i = first.id

        while i < last.id
          scope.delete_all ["id BETWEEN ? AND ?", i, i + batch - 1]

          puts "Deleted records from #{i} to #{i + batch - 1} (max #{last.id}, total: #{total})"

          i += batch
        end

        puts "Done!"
      else
        puts "No records found"
      end
    end

    desc "Remove old fights"
    task :fights => :environment do
      time_limit = 1.month.ago

      old_fights = Fight.scoped(:conditions => ["created_at < ?", time_limit])

      puts "Removing old fights..."
      
      remove_data(old_fights)
    end

    desc "Remove old bank operations"
    task :bank_operations => :environment do
      time_limit = 1.month.ago

      old_operations = BankOperation.scoped(:conditions => ["created_at < ?", time_limit])

      puts "Removing old bank operations..."

      remove_data(old_operations)
    end

    desc "Remove old news"
    task :news => :environment do
      time_limit = 5.days.ago

      old_news = News::Base.scoped(:conditions => ["created_at < ?", time_limit])

      puts "Removing old news..."

      remove_data(old_news)
    end

    desc "Remove old application requests"
    task :app_requests => :environment do
      time_limit = 15.days.ago

      old_requests = AppRequest::Base.scoped(:conditions => ["created_at < ?", time_limit])

      puts "Removing old application requests..."

      remove_data(old_requests)
    end
    
    
    desc "Remove old logged events"
    task :events => :environment do
      time_limit = 2.weeks.ago

      old_events = LoggedEvent.scoped(:conditions => ["created_at < ?", time_limit])

      puts "Removing logged events..."

      remove_data(old_events)
    end
    
    desc "Remove old tracking requests"
    task :tracking_requests => :environment do
      puts "Removing tracking requests..."

      date_limit = 30

      while true
        date = Date.today - date_limit
      
        if $redis.exists("tracking_requests_#{ date }")
          $redis.del("tracking_requests_#{ date }")
        else
          break
        end
      
        date_limit += 1
      end
      
      time_limit = 48
      hours = time_limit - (Time.now.hour + 24)
    
      if hours > 0
        date = Date.today - 3
        hours = 24 - hours
        
        hours.downto(1){|hour| $redis.del("tracking_requests_hourly_#{ date }_#{ hour }")}
      else
        date = Date.today - 2
        hours = 24
    
        hours.downto(1){|hour| $redis.del("tracking_requests_hourly_#{ date }_#{ hour }")}
      end
      
      puts "Done!"
      
    end
    
    desc "Remove old monster chats"
    task :monster_chats => :environment do
      recent_monster = Monster.first(:conditions => ["updated_at < ?", 1.day.ago], :order => :id)
      
      if recent_monster
        old_monster_chat_keys = $redis.keys("chat_monster_*")
        old_monster_chat_keys.reject!{|key| key >= "chat_#{recent_monster.chat_id}" }
        
        puts "Removing #{old_monster_chat_keys.size} old monster chats from redis..."
        
        $redis.del(*old_monster_chat_keys) unless old_monster_chat_keys.empty?
        
        
        old_monster_online_keys = $redis.keys("online_characters_chat_monster_*")
        old_monster_online_keys.reject!{|key| key >= "online_characters_chat_#{recent_monster.chat_id}" }
        
        puts "Removing #{old_monster_online_keys.size} old monster online-lists from redis..."
        
        $redis.del(*old_monster_online_keys) unless old_monster_online_keys.empty?
      end
    end
  end
end