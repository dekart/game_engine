namespace :app do
  namespace :setup do
    desc "Setup application stylesheets"
    task :stylesheets => :environment do
      Asset.update_sass
      Skin.update_sass

      Sass::Plugin.update_stylesheets
    end

    desc "Re-import development assets. All existing assets will be destroyed!"
    task :import_assets, :destroy_old, :needs => :environment do |task, options|
      if options["destroy_old"] == "true"
        puts "Destroying existing assets..."

        Asset.destroy_all
      end

      require Rails.root.join("db", "seeds", "assets")

      Rake::Task["app:setup:stylesheets"].execute
    end

    desc "Re-import settings"
    task :reimport_settings => :environment do
      require Rails.root.join("db", "seeds", "settings")
    end
    
    desc "Subscribe to real-time updates"
    task :subscriptions => :environment do
      puts 'Setting up real-time update subscriptions...'
      
      authenticator = Mogli::Authenticator.new(Facebooker2.app_id, Facebooker2.secret, nil)

      client = Mogli::AppClient.new(authenticator.get_access_token_for_application)
      client.application_id = Facebooker2.app_id
      
      client.subscribe_to_model(Mogli::User, 
        :fields => [:first_name, :last_name, :email, :gender, :timezone, :third_party_id, :locale],
        :callback_url => Facebooker2.callback_url + '/users/subscribe',
        :verify_token => Digest::MD5.hexdigest(Facebooker2.secret)
      )
      
      puts 'Done!'
    end
  end
end
