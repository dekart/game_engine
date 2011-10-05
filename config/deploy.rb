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
    app.cache_fb_connect_js
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
    task :nginx do
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
    task :cron, :roles => :app do
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

      run %{
        mysqldump \
          -u #{ database_config[:username] } --password='#{ database_config[:password] }' \
          --ignore-table=#{ database_config[:database] }.logged_events \
          #{ database_config[:database] } > #{ dump_path }
      }
    end
    
    desc "Setup database"
    task :setup, :roles => :db, :only => {:primary => true} do
      run "cd #{current_path}; bundle exec rake db:setup --trace"
    end
    
    desc "Package all non-packaged backups"
    task :package_backups, :roles => :db, :only => {:primary => true} do
      run "gzip *.sql"
    end
  end

  namespace :dependencies do
    desc "Install environment gems"
    task :system_gems, :roles => :app do
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
    task :bundled_gems, :roles => :app do
      run "rm -rf ~/.gems/ruby/1.8/cache; cd #{release_path}; bundle install --deployment --without development test"
    end
  end
  
  namespace :app do
    desc "Setup application"
    task :setup, :roles => :app do
      run "cd #{release_path}; bundle exec rake app:setup --trace"
    end
    
    desc "Cache Facebook Connect javascript code"
    task :cache_fb_connect_js, :roles => :app do
      folder_path = "#{release_path}/public/javascripts/cache"
      
      run "mkdir -p #{folder_path} && wget http://connect.facebook.net/en_US/all.js -O #{folder_path}/facebook_connect.js"
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
  before "deploy:symlink", "deploy:app:cache_fb_connect_js"
end


