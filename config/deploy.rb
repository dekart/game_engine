require "active_support"
require "yaml"
require "uri"
require "capistrano/ext/multistage"

set :stages, %w(staging production)
set :default_stage, "production"

set :use_sudo, false

set :scm, "git"
set :deploy_via, :remote_cache

set :db_config, YAML.load_file(File.expand_path("../database.yml", __FILE__))

default_environment["PATH"] = "$PATH:~/.gem/ruby/1.8/bin"

namespace :deploy do
  desc "Restart service"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Start service"
  task :start, :roles => :app do
    puts "Start task not implemented"
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

    desc "Generate Facebooker config file"
    task :facebooker do
      config = YAML.dump(rails_env => facebooker_config.stringify_keys)

      put(config, "#{release_path}/config/facebooker.yml")
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
    task :backup, :roles => :db do
      dump_path = '%s/dump.%s.%d.sql' % [shared_path, db_config[rails_env]["database"], Time.now.to_i]

      run "mysqldump -u %s --password='%s' %s > %s" % [
        db_config[rails_env]["username"],
        db_config[rails_env]["password"],
        db_config[rails_env]["database"],
        dump_path
      ]
      
      run "gzip #{dump_path}"
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

      run "gem install bundler -v=0.9.26 && gem cleanup bundler"
      run "gem install rails -v=2.3.8"
      run "gem install rack -v=1.0.1"
    end

    desc "Install required gems"
    task :bundled_gems, :roles => :app do
      run "cd #{release_path}; bundle install --without=test"
    end
  end
  
  namespace :app do
    desc "Bootstrap application data"
    task :bootstrap, :roles => :app do
      run "cd #{current_path}; rake db:seed --trace"
    end

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
  end
end

# Application setup
after "deploy:setup", "deploy:dependencies:system_gems"


# All deploys
after "deploy:update_code", "deploy:dependencies:bundled_gems"
after "deploy:update_code", "deploy:configure:facebooker"

["deploy", "deploy:migrations", "deploy:cold"].each do |t|
  after t, "deploy:configure:apache"
  after t, "deploy:configure:cron"
  after t, "deploy:cleanup"
end


# First deploy
after "deploy:cold", "deploy:app:bootstrap"
after "deploy:cold", "deploy:app:setup"


# Ordinary deploys
before "deploy:migrations", "deploy:db:backup"

on :before, :only => ["deploy", "deploy:migrations"] do
  before "deploy:symlink", "deploy:app:setup"
end


