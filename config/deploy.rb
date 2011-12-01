require "active_support"
require "yaml"
require "uri"
require "capistrano/ext/multistage"
require "lib/core_ext/hash"

set :stages, %w(staging production)
set :default_stage, "production"

set :use_sudo, false

set :scm, "git"
set :deploy_via, :remote_cache

default_environment["PATH"] = "$PATH:~/.gem/ruby/1.8/bin"

namespace :deploy do
  desc "Deploy 'cold' application"
  task :cold do
    update
    db.setup
    app.setup
  end
  
  desc "Restart service"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Stop service"
  task :stop, :roles => :app do
    puts "Stop task not implemented"
  end

  namespace :configure do
    desc "Updates apache virtual host config"
    task :apache do
      template = ERB.new(
        File.read(File.expand_path("../deploy/templates/apache.conf.erb", __FILE__))
      )

      config = template.result(binding)

      put(config, "#{shared_path}/apache_vhost.conf")
    end

    desc "Updates nginx virtual host config"
    task :nginx, :roles => :web do
      template = ERB.new(
        File.read(File.expand_path("../deploy/templates/nginx.conf.erb", __FILE__))
      )

      config = template.result(binding)

      put(config, "#{shared_path}/nginx.conf")
    end

    desc "Generate Facebook config file"
    task :facebook do
      config = YAML.dump(rails_env => facebook_config.deep_stringify_keys)

      put(config, "#{release_path}/config/facebook.yml")
    end
    
    desc "Generate DB config file"
    task :database do
      config = YAML.dump(rails_env => database_config.deep_stringify_keys)

      put(config, "#{release_path}/config/database.yml")
    end

    desc "Generate Application config file"
    task :settings do
      config = YAML.dump(rails_env => settings_config.deep_stringify_keys)

      put(config, "#{release_path}/config/settings.yml")
    end

    desc "Install cron jobs"
    task :cron, :roles => :background do
      template = ERB.new(
        File.read(File.expand_path("../deploy/templates/crontab.erb", __FILE__))
      )

      config = template.result(binding)

      put(config, "#{shared_path}/crontab.conf")

      run "crontab #{shared_path}/crontab.conf"
    end
  end

  namespace :web do
    desc "Disable application"
    task :disable, :roles => :web do
      template = ERB.new(
        File.read(File.expand_path("../deploy/templates/maintenance.html.erb", __FILE__))
      )

      downtime_length = ENV['DOWNTIME_LENGTH'] ? eval(ENV['DOWNTIME_LENGTH']) : 10.minutes

      html = template.result(binding)

      put(html, "#{shared_path}/system/maintenance.html")
    end
  end

  namespace :db do
    desc "Backup database"
    task :backup, :roles => :db, :only => {:primary => true} do
      dump_path = 'dump.%s.%d.sql' % [database_config[:database], Time.now.to_i]
      
      common_options = "--user='#{ database_config[:username] }' --password='#{ database_config[:password] }' --default-character-set='#{ database_config[:encoding] }' --set-charset"
      
      run "mysqldump #{common_options} --no-data #{ database_config[:database] } >> #{ dump_path }" # Dumping structure
      run "mysqldump #{common_options} --no-create-info --ignore-table='#{ database_config[:database] }.logged_events' #{ database_config[:database] } >> #{ dump_path }"
    end
    
    desc "Setup database"
    task :setup, :roles => :db, :only => {:primary => true} do
      run "cd #{current_path}; rake db:setup --trace"
    end
    
    desc "Package all non-packaged backups"
    task :package_backups, :roles => :db, :only => {:primary => true} do
      run "nohup gzip *.sql"
    end
    
    desc "Generates SQL for access granting for each app server"
    task :generate_access_sql do
      top.find_servers(:roles => :app).each do |server|
        puts "GRANT ALL PRIVILEGES ON `%s`.* TO '%s'@'%s' IDENTIFIED BY '%s' WITH GRANT OPTION;" % [
          database_config[:database],
          database_config[:username],
          server.options[:private_ip] || 'localhost',
          database_config[:password]
        ]
      end
    end    
  end

  namespace :dependencies do
    desc "Install environment gems"
    task :system_gems do
      config = YAML.dump(
        :verbose        => true,
        "gem"           => "--no-ri --no-rdoc --user-install",
        :bulk_threshold => 1000,
        :sources        => %w{http://gemcutter.org http://gems.github.com},
        :benchmark      => false,
        :backtrace      => false,
        :update_sources => true
      )

      put(config, ".gemrc")

      run "gem install bundler -v=1.0.14"
    end

    desc "Install required gems"
    task :bundled_gems do
      run "rm -rf ~/.gems/ruby/1.8/cache; cd #{release_path}; bundle install --deployment --without development test"
    end
  end
  
  namespace :app do
    desc "Setup application"
    task :setup, :roles => :app do
      run "cd #{release_path}; rake app:setup --trace"
    end
  end
  
  namespace :maintenance do
    desc "Configure warning message about scheduled downtime"
    task :schedule, :roles => :app do
      settings = {
        :start  => eval(ENV['DOWNTIME_START']).from_now.utc,
        :length => eval(ENV['DOWNTIME_LENGTH'])
      }

      config = YAML.dump(settings)

      put(config, "#{current_path}/public/system/maintenance.yml")
    end

    desc "Stop cron"
    task :stop_cron, :roles => :background do
      run "crontab -r"
    end
  end
end

# Application setup
after "deploy:setup", "deploy:dependencies:system_gems"


# All deploys
after "deploy:update_code", "deploy:dependencies:bundled_gems"
after "deploy:update_code", "deploy:configure:facebook"
after "deploy:update_code", "deploy:configure:database"
after "deploy:update_code", "deploy:configure:settings"

["deploy", "deploy:migrations", "deploy:cold"].each do |t|
  after t, "deploy:configure:nginx"
  after t, "deploy:configure:cron"
  after t, "deploy:cleanup"
end


# Ordinary deploys
before "deploy:migrations", "deploy:db:backup"
after "deploy:migrations", "deploy:db:package_backups"

on :before, :only => ["deploy", "deploy:migrations"] do
  before "deploy:symlink", "deploy:app:setup"
end


