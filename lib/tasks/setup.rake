namespace :app do
  desc 'Setup application'
  task :setup => [:environment, 'setup:assets', 'setup:stylesheets', 'setup:settings', 'setup:experience', 'setup:subscriptions']
  
  namespace :setup do
    desc "Setup application stylesheets"
    task :stylesheets => :environment do
      Asset.update_sass

      Sass::Plugin.update_stylesheets
    end

    desc "Re-import development assets. All existing assets will be destroyed!"
    task :assets, [:destroy_old] => :environment do |task, options|
      if options["destroy_old"] == "true" || ENV['DESTROY_ASSETS'] == 'true'
        puts "Destroying existing assets..."

        Asset.destroy_all
      end

      require Rails.root.join("db", "seeds", "assets")

      Rake::Task["app:setup:stylesheets"].execute
    end

    desc "Re-import settings"
    task :settings => :environment do
      require Rails.root.join("db", "seeds", "settings")
    end
    
    desc "Subscribe to real-time updates"
    task :subscriptions => :environment do
      puts 'Setting up real-time update subscriptions...'
      
      config = Facepalm::Config.default
      updates = Koala::Facebook::RealtimeUpdates.new(
        :app_id => config.app_id, 
        :secret => config.secret
      )
      
      begin
        updates.subscribe(
          'user', 
          'first_name, last_name, email, timezone, locale',
          config.callback_url('http://') + '/users/subscribe',
          config.subscription_token
        )
    
        puts 'Done!'
      rescue Exception => e
        puts "Error while doing real-time update subscription:"
        puts e
      end
    end
    
    desc "Generate experience table for levels"
    task :experience, [:regenerate] => :environment do |task, options|
      if Character::Levels::EXPERIENCE.empty? || options['regenerate'] == 'true'
        puts 'Generating experience table for levels...'
        
        experience = [0]
      
        1000.times do |i|
          experience[i + 1] = ((experience[i].to_i * 1.02 + (i + 1) * 10).round / 10.0).round * 10
        end
        
        File.open(Character::Levels::DATA_FILE, 'w+') do |file|
          file.puts(*experience)
        end
        
        puts 'Done!'
      end
    end
    
    desc "Generate SSL certificates for a specified environment"
    task :certificate, :environment do |taks, options|
      env = options.environment || "production"
      
      certificate_path = File.expand_path("../../../config/deploy/certificates/#{ env }", __FILE__)
      
      system("openssl req -new -newkey rsa:2048 -nodes -keyout #{ certificate_path }.key -out #{ certificate_path }.csr")
    end
  end
end
