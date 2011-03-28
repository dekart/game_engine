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
  :callback_url     => "http://your_domain",

  :set_asset_host_to_callback_url => true
}

set :database_config, {
  :adapter  => "mysql",
  :host     => "localhost",
  :database => "your_db_name",
  :username => "your_db_user",
  :password => "your_db_password"
}

set :redis_config, {
    :host => "127.0.0.1",
    :port => 6379,
    :db => 0
}
