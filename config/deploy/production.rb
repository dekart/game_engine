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
