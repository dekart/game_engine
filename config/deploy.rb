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
      run "cd #{current_path}; rake blogbox:jobs:update_references --trace"
    end
  end

  desc "Bootstrap application data"
  task :bootstrap, :roles => :app do
    run "cd #{current_path}; rake app:bootstrap"
  end
end

["deploy:jobs:stop"].each do |t|
  before "deploy", t
  before "deploy:migrations", t
end

["deploy:jobs:update_references", "deploy:bootstrap", "deploy:jobs:start", "deploy:cleanup"].each do |t|
  after "deploy", t
  after "deploy:migrations", t
end