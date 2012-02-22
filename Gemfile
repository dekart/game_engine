source 'http://rubygems.org'

gem "rails", "3.2.1"

gem 'mysql2'
gem "memcache-client",  "~> 1.8.5"
gem "will_paginate",    "~> 3.0.2"
gem "paperclip",        "~> 2.5.0"
gem "aws-s3",           "~> 0.6.2"
gem "delayed_job_active_record", "~> 0.3.1"
gem 'daemons'
gem "json_pure",        "~> 1.6.5"
gem "haml",             "~> 3.1.4"
gem "RedCloth",         "~> 4.2.9"
gem "nokogiri",         "~> 1.5.0"
gem "redis",            "~> 2.2.2"
gem "state_machine",    "~> 1.1.1"

gem "cubus-settingslogic", "~> 2.2.0"
gem "rufus-scheduler",  "~> 2.0.16"

gem "multi_json",       "~> 1.0.4"
gem "faraday",          "~> 0.7.5"

gem "koala",            "~> 1.2.1"
gem 'facepalm',         '~> 0.2'

gem 'jquery-rails'


group :development do
  gem "capistrano",   "~> 2.9.0"
  gem "capistrano-ext"
  gem "net-scp",      "~> 1.0.4"
  
  # TODO: bug with ruby-debug19 http://stackoverflow.com/questions/8251349/ruby-threadptr-data-type-error
  #gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'linecache19', :git => 'git://github.com/mark-moseley/linecache'
  gem 'ruby-debug-base19x', '~> 0.11.30.pre4'
  gem 'ruby-debug19', :require => 'ruby-debug'
end

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
  gem 'execjs'
  gem 'therubyracer'
end

group :test do
  gem 'turn', :require => false
  
  gem "rspec-rails",        "~> 2.8.1"
  gem "autotest-rails",     "~> 4.1.1"
  gem "shoulda-matchers",   "~> 1.0.0"
  gem "factory_girl_rails", "~> 1.5.0"
  gem "timecop",            "0.3.5"
  gem "spork",              "~> 0.8.5"
  gem "database_cleaner",   "~> 0.7.1"
end