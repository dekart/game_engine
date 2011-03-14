set :application, "sword"

set :repository,  "git@itvektor.ru:facebook/knights.git"
set :branch,  "master"

role :app, "173.45.238.123"
role :web, "173.45.238.123"
role :db,  "173.45.238.123", :primary => true

set :user, "game"

set :deploy_to, "/home/#{user}/#{application}"

set :rails_env, "production"

default_environment["RAILS_ENV"] = "production"

set :facebooker_config, {
  :app_id           => "81958551648",
  :api_key          => "eccd02101c4a358ffe9590fdfa347954",
  :secret           => "1a7e8b3eb1e5d3999d54d286b5d1c5e4",
  :canvas_page_name => "sword-and-magic",
  :callback_url     => "http://sword.it-vektor.ru",

  :set_asset_host_to_callback_url => true
}

set :database_config, {
  :adapter  => "mysql",
  :host     => "localhost",
  :database => "sword_production",
  :username => "sword",
  :password => "alskdjf85hg"
}