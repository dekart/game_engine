source 'http://rubygems.org'

gem "rails", "3.2.1"

gem 'mysql2'
gem "memcache-client",  "~> 1.8.5"
gem "will_paginate",    "~> 3.0.2"
gem "paperclip",        "~> 2.5.0"
gem 'cocaine',          '~> 0.3.2' # Dependency of paperclip, should set a strict version to avoid this bug: https://github.com/thoughtbot/paperclip/issues/1038
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
gem 'facepalm',         '~> 0.2', :git => 'git://github.com/dekart/facepalm.git'

gem 'jquery-rails'

gem 'i18n-js'

gem 'yajl-ruby', :require => 'yajl'

gem 'dynamic_form',     '~> 1.1.4'

gem 'compass-rails'

gem 'visibilityjs'

group :development do
  gem "capistrano",   "~> 2.9.0"
  gem "capistrano-ext"
  gem "net-scp",      "~> 1.0.4"
end

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
  gem 'execjs'
  gem 'therubyracer'

  gem 'oily_png'

  gem 'eco'
end

group :test do
#  gem 'turn', :require => false

  gem "timecop"
  gem 'minitest'
  gem 'minitest-rails'
  gem 'factory_girl'
  gem 'guard-minitest'

  gem 'guard'
  gem 'rb-fsevent', '~> 0.9.1'
  gem 'growl'
end