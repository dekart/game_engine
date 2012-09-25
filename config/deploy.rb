require 'bundler/capistrano'
require "active_support"
require "active_support/core_ext/numeric/time"
require "yaml"
require "uri"
require "capistrano/ext/multistage"
require "./lib/core_ext/hash"
require "./lib/capistrano/capture_fix"
require './config/boot'

set :stages, %w(staging production)
set :default_stage, "production"

set :use_sudo, false

set :scm, "git"
set :deploy_via, :remote_cache

set :rake, "bundle exec rake --trace"

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

      common_options = "--host='#{ database_config[:host] }' --user='#{ database_config[:username] }' --password='#{ database_config[:password] }' --default-character-set='#{ database_config[:encoding] }' --set-charset"

      run "mysqldump #{common_options} --no-data #{ database_config[:database] } >> #{ dump_path }" # Dumping structure
      run "mysqldump #{common_options} --no-create-info --ignore-table='#{ database_config[:database] }.logged_events' #{ database_config[:database] } >> #{ dump_path }"
    end

    desc "Setup database"
    task :setup, :roles => :db, :only => {:primary => true} do
      run "cd #{release_path}; #{rake} db:setup"
    end

    desc "Package all non-packaged backups"
    task :package_backups, :roles => :db, :only => {:primary => true} do
      run "nohup gzip *.sql"
    end

    desc "Cleanup old backups"
    task :cleanup_backups, :roles => :db, :only => {:primary => true} do
      backups = capture("ls -xt | grep dump.%s || true" % database_config[:database]).split.reverse

      backups_to_remove = backups[0 ... -5]

      if backups_to_remove.empty?
        logger.important "No old backups to clean up"
      else
        logger.info "Removing old DB backups (#{backups_to_remove.size} of 5)..."

        run "rm -rf %s" % backups_to_remove.join(' ')
      end
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
        "gem"           => "--no-ri --no-rdoc",
        :bulk_threshold => 1000,
        :sources        => %w{http://gemcutter.org http://gems.github.com},
        :benchmark      => false,
        :backtrace      => false,
        :update_sources => true
      )

      put(config, ".gemrc")

      run "gem install bundler -v=1.0.21"
      run "gem install rake -v=0.9.2.2"
      run "rbenv rehash"
    end

    desc "Install required gems"
    task :bundled_gems do
      run "rm -rf ~/.gems/ruby/1.8/cache; cd #{release_path}; bundle install --deployment --without development test"
    end
  end

  namespace :app do
    desc "Setup application"
    task :setup, :roles => :app do
      run "cd #{release_path}; #{rake} app:setup"
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
      run "crontab -r || true"
    end
  end

  namespace :assets do
    desc "Export i18n locales to javascript"
    task :export_i18n, :roles => :web do
      run "cd #{release_path}; #{ rake } i18n:js:export"
    end
  end
end

# Application setup
after "deploy:setup", "deploy:dependencies:system_gems"


# All deploys
before "deploy:update_code", "deploy:maintenance:stop_cron"

after "deploy:finalize_update", "deploy:configure:facebook"
after "deploy:finalize_update", "deploy:configure:database"
after "deploy:finalize_update", "deploy:configure:settings"

before "deploy:assets:precompile", "deploy:assets:export_i18n"

["deploy", "deploy:migrations", "deploy:cold"].each do |t|
  after t, "deploy:configure:nginx"
  after t, "deploy:configure:cron"
  after t, "deploy:cleanup"
end


# Ordinary deploys
unless ENV['BACKUP'] == 'false'
  before "deploy:migrations", "deploy:db:backup"
  after "deploy:migrations", "deploy:db:package_backups"
  after "deploy:migrations", "deploy:db:cleanup_backups"
end

on :before, :only => ["deploy", "deploy:migrations"] do
  before "deploy:symlink", "deploy:app:setup"
end


