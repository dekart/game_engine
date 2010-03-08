require "yaml"
require "uri"

set :application, "sword"
set :repository,  "git@itvektor.ru:facebook/knights.git"

set :use_sudo, false

role :app, "173.45.238.123"
role :web, "173.45.238.123"
role :db,  "173.45.238.123", :primary => true

set :deploy_to, "/home/#{application}"

set :user, application

set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache

set :rails_env, "production"
default_environment["RAILS_ENV"] = "production"

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

  namespace :jobs do
    desc "Install cron jobs"
    task :install_cron do
      config = <<-CODE
        RAILS_ENV=#{rails_env}
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

        * * * * * cd #{current_path} && test `ps ax | grep -E 'delayed_job' | wc -l` -le 3 && #{current_path}/script/delayed_job >> #{shared_path}/log/delayed_job.log 2>&1
      CODE

      put(config, "#{shared_path}/crontab.conf")

      run "crontab #{shared_path}/crontab.conf"
    end
  end

  desc "Bootstrap application data"
  task :bootstrap, :roles => :app do
    run "cd #{current_path}; rake db:seed"
  end

  desc "Updates apache virtual host config"
  task :update_apache_config do
    facebook_config = YAML.load_file(File.join(File.dirname(__FILE__), "facebooker.yml"))

    config = <<-CODE
      <VirtualHost *>
        ServerName #{URI.parse(facebook_config["production"]["callback_url"]).host}
        DocumentRoot #{current_path}/public
      </VirtualHost>
    CODE

    put(config, "#{shared_path}/apache_vhost.conf")
  end

  namespace :db do
    desc "Backup database"
    task :backup, :roles => :app do
      run "cd #{current_path}; rake backup:db"
    end
  end

  namespace :dependencies do
    desc "Install environment gems"
    task :system_gems, :roles => :app do
      config = YAML.dump(
        :verbose        => true,
        "gem"           => "--no-ri --no-rdoc",
        :bulk_threshold => 1000,
        :sources        => %w{http://gemcutter.org http://gems.rubyforge.org http://gems.github.com},
        :benchmark      => false,
        :backtrace      => false,
        :update_sources => true
      )

      put(config, ".gemrc")

      run "gem install bundler -v=0.8.1"
      run "gem install rails -v=2.3.5"
      run "gem install rack -v=1.0.1"
    end

    desc "Install required gems"
    task :bundled_gems, :roles => :app do
      run "cd #{release_path}; gem bundle --only production"
    end
  end

  desc "Setup Facebook application"
  task :setup_facebook_app, :roles => :app do
    run "cd #{current_path}; rake app:setup:facebook_app"
  end

  desc "Setup application stylesheets"
  task :setup_stylesheets, :roles => :app do
    run "cd #{current_path}; rake app:setup:stylesheets"
  end
end

["deploy:dependencies:system_gems"].each do |t|
  after "deploy:setup", t
end

before "deploy:migrations", "deploy:db:backup"

after "deploy:update_code", "deploy:dependencies:bundled_gems"

["deploy:setup_stylesheets", "deploy:update_apache_config", "deploy:jobs:install_cron", "deploy:cleanup"].each do |t|
  after "deploy", t
  after "deploy:migrations", t
end

["deploy:bootstrap", "deploy:setup_facebook_app", "deploy:setup_stylesheets", "deploy:update_apache_config", "deploy:jobs:install_cron"].each do |t|
  after "deploy:cold", t
end