set :application, "your_app_alias"

set :repository,  "git@git.railorz.com:facebook/#{application}.git"
set :branch,  "master"

server "your_server", :web, :app, :db, :primary => true

set :user, "your_user_name"

set :deploy_to, "/home/#{user}/#{application}"

set :rails_env, "production"

default_environment["RAILS_ENV"] = "production"

set :facebooker_config, {
  :app_id           => "your_fb_app_id",
  :api_key          => "your_fb_api_key",
  :secret           => "your_fb_api_secret",
  :canvas_page_name => "your_fb_canvas_page",
  :callback_domain  => "your_domain"
}

set :database_config, {
  :adapter  => "mysql",
  :host     => "localhost",
  :database => "your_db_name",
  :username => "your_db_user",
  :password => "your_db_password"
}

set :settings_config, {
  :cache => {
    :server => 'localhost'
  },
  :session => {
    :memcache_server  => 'localhost',
    :key              => '_game_engine2',
    :secret           => 'ab08c85360590a72ea4c70ff82fcf09714f333ba13723cb9f477eb8f50c7dd4f3328ca981cc7ee2df27367f6daeedd29c51cb00fb5fc3bf146ab1e90ccb1f878'
  },
  :redis => {
    :host => '127.0.0.1',
    :port => 6379,
    :db   => 0,
  },
  :event_logging => {
    :enabled => true
  }
}
