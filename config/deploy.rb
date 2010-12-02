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

  namespace :jobs do
    desc "Install cron jobs"
    task :install_cron, :roles => :app do
      template = ERB.new(
        File.read(File.expand_path("../deploy/templates/crontab.erb", __FILE__))
      )

      config = template.result(binding)

      put(config, "#{shared_path}/crontab.conf")

      run "crontab #{shared_path}/crontab.conf"
    end
  end

  desc "Bootstrap application data"
  task :bootstrap, :roles => :app do
    run "cd #{current_path}; rake db:seed --trace"
  end

  desc "Updates apache virtual host config"
  task :update_apache_config do
    template = ERB.new(
      File.read(File.expand_path("../deploy/templates/apache.conf.erb", __FILE__))
    )

    config = template.result(binding)

    put(config, "#{shared_path}/apache_vhost.conf")
  end

  desc "Updates nginx virtual host config"
  task :update_nginx_config do
    template = ERB.new(
      File.read(File.expand_path("../deploy/templates/nginx.conf.erb", __FILE__))
    )

    config = template.result(binding)

    put(config, "#{shared_path}/nginx.conf")
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

  desc "Setup Facebook application"
  task :setup_facebook_app, :roles => :app do
    run "cd #{release_path}; rake app:setup:facebook_app"
  end

  desc "Import assets"
  task :import_assets, :roles => :app do
    run "cd #{release_path}; rake app:setup:import_assets --trace"
  end

  desc "Setup application stylesheets"
  task :setup_stylesheets, :roles => :app do
    run "cd #{release_path}; rake app:setup:stylesheets --trace"
  end

  desc "Setup application settings"
  task :setup_settings, :roles => :app do
    run "cd #{release_path}; rake app:setup:reimport_settings --trace"
  end

  desc "Configure warning message about scheduled downtime"
  task :schedule_maintenance, :roles => :app do
    settings = {
      :start  => eval(ENV['DOWNTIME_START']).from_now.utc,
      :length => eval(ENV['DOWNTIME_LENGTH'])
    }

    config = YAML.dump(settings)

    put(config, "#{current_path}/public/system/maintenance.yml")
  end

  desc "Remove maintenance warning"
  task :finish_maintenance, :roles => :app do
    run "rm #{current_path}/public/system/maintenance.yml"
  end

  desc "Generate Facebooker config file"
  task :generate_facebooker_config do
    config = YAML.dump(rails_env => facebooker.stringify_keys)

    put(config, "#{release_path}/config/facebooker.yml")
  end
end

["deploy:dependencies:system_gems"].each do |t|
  after "deploy:setup", t
end

before "deploy:migrations", "deploy:db:backup"

["deploy:dependencies:bundled_gems", "deploy:generate_facebooker_config"].each do |t|
  after "deploy:update_code", t
end

on :before, :only => "deploy:cold" do
  after "deploy:cold", "deploy:setup_stylesheets"
end

on :before, :only => ["deploy", "deploy:migrations"] do
  ["deploy:setup_settings", "deploy:import_assets", "deploy:setup_stylesheets"].each do |t|
    before "deploy:symlink", t
  end
end

["deploy:update_nginx_config", "deploy:jobs:install_cron", "deploy:cleanup"].each do |t|
  after "deploy", t
  after "deploy:migrations", t
end

["deploy:bootstrap", "deploy:setup_facebook_app", "deploy:import_assets", "deploy:setup_stylesheets", "deploy:update_apache_config", "deploy:jobs:install_cron"].each do |t|
  after "deploy:cold", t
end