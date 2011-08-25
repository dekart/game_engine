namespace :app do
  namespace :cheating do
    def report_users_by_ip(limit, field)
      User.scoped(
        :select => "DISTINCT #{ field }, count(id) as ids_per_ip", 
        :conditions => "banned IS NOT TRUE AND #{ field } IS NOT NULL AND #{ field } != 2147483647",
        :group => "#{ field } HAVING ids_per_ip >= #{ limit }", 
        :order => "ids_per_ip DESC"
      ).each do |user|
        puts
        puts "IP: %s (%d) - %d users" % [user.send(field), user[field], user[:ids_per_ip]]

        puts "-" * 50
        puts

        characters = Character.scoped(
          :joins => :user, 
          :conditions => ["users.#{ field } = ?", user[field]], 
          :order => "level DESC, characters.created_at"
        )

        characters.each do |character|
          puts "%6d  %15s  %4d  %30s  %40s  %10d  %10d  %s" % [
            character.id, 
            character.name.to_s[0, 15], 
            character.level,
            character.user.full_name.to_s[0, 30], 
            character.user.email.to_s[0, 40],
            character.user[:signup_ip],
            character.user[:last_visit_ip],
            character.user.last_visit_at.to_s(:db)
          ]
        end

        puts
        puts "Character IDs: %s" % characters.map(&:id).join(',')
        puts
      end

      true
    end
    
    desc "Report duplicate users by signup ip"
    task :signup_ip, :limit, :needs => :environment do |task, options|
      limit = options.limit ? options.limit.to_i : 5
      
      puts "Reporting users who signed up from the same IP (%d users minimum)" % limit
      
      report_users_by_ip(limit, :signup_ip)

      puts "Done!"
    end
    
    desc "Report duplicate users by last visit ip"
    task :last_visit_ip, :limit, :needs => :environment do |task, options|
      limit = options.limit ? options.limit.to_i : 5
      
      puts "Reporting users who logged in from the same IP (%d users minimum)" % limit
      
      report_users_by_ip(limit, :last_visit_ip)
      
      puts "Done!"
    end
  end
end