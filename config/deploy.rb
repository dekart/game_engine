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
    desc "Start background jobs"
    task :start, :roles => :app do
      run "cd #{current_path}; ./script/jobs -e production start"
    end

    desc "Stop background jobs"
    task :stop, :roles => :app do
      run "cd #{current_path}; ./script/jobs -e production stop"
    end

    desc "Start background jobs"
    task :restart, :roles => :app do
      run "cd #{current_path}; ./script/jobs -e production restart"
    end

    desc "Update references"
    task :update_references, :roles => :app do
      run "cd #{current_path}; rake app:jobs:update_references --trace"
    end
  end

  desc "Bootstrap application data"
  task :bootstrap, :roles => :app do
    run "cd #{current_path}; rake app:bootstrap:assets"
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
    desc "Install bundler gem"
    task :bundler, :roles => :app do
      run "gem install bundler --no-ri --no-rdoc --source http://gemcutter.org"
    end

    desc "Install Rails"
    task :rails, :roles => :app do
      run "gem install rails -v=2.3.5 --no-ri --no-rdoc"
    end

    desc "Install required gems"
    task :gems, :roles => :app do
      run "cd #{release_path}; gem bundle --only production"
    end
  end
end

before "deploy:migrations", "deploy:db:backup"
after "deploy:update_code", "deploy:dependencies:gems"

["deploy:dependencies:bundler", "deploy:dependencies:rails"].each do |t|
  before "deploy_cold", t
end

["deploy:jobs:stop"].each do |t|
  before "deploy", t
  before "deploy:migrations", t
end

["deploy:update_apache_config", "deploy:jobs:start", "deploy:jobs:update_references", "deploy:cleanup"].each do |t|
  after "deploy", t
  after "deploy:migrations", t
end

["deploy:bootstrap", "deploy:update_apache_config", "deploy:jobs:start"].each do |t|
  after "deploy:cold", t
end