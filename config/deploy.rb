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

        * * * * * cd #{current_path} && test `ps ax | grep -E 'delayed_job' | wc -l` -le 3 && #{current_path}/script/delayed_job >> #{shared_path}/log/delayed_job.log 2>&1
      CODE

      put(config, "#{shared_path}/crontab.conf")

      run "crontab #{shared_path}/crontab.conf"
    end

    desc "Update references"
    task :update_references, :roles => :app do
      run "cd #{current_path}; rake app:jobs:update_references --trace"
    end
  end

  desc "Bootstrap application data"
  task :bootstrap, :roles => :app do
    run "cd #{current_path}; rake db:seed app:bootstrap:assets"
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
      run "gem install bundler --no-ri --no-rdoc --source http://gemcutter.org"
      run "gem install rails -v=2.3.5 --no-ri --no-rdoc"
      run "gem install rack -v=1.0.1 --no-ri --no-rdoc"
      run "gem install daemons --no-ri --no-rdoc"
    end

    desc "Install required gems"
    task :bundled_gems, :roles => :app do
      run "cd #{release_path}; gem bundle --only production"
    end
  end
end

["deploy:dependencies:system_gems"].each do |t|
  after "deploy:setup", t
end

before "deploy:migrations", "deploy:db:backup"

after "deploy:update_code", "deploy:dependencies:bundled_gems"

["deploy:update_apache_config", "deploy:jobs:install_cron", "deploy:jobs:update_references", "deploy:cleanup"].each do |t|
  after "deploy", t
  after "deploy:migrations", t
end

["deploy:bootstrap", "deploy:update_apache_config", "deploy:jobs:start"].each do |t|
  after "deploy:cold", t
end