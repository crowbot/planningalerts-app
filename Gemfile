source "https://rubygems.org"

gem 'rails', '4.2.7'
gem 'mysql2', '> 0.3'
gem 'pg'

# Allow us to use `caches_page`
gem "actionpack-page_caching"
# Need to support sweepers
gem "rails-observers"

gem 'coffee-rails'
gem "compass-rails"
gem "compass-blueprint"
gem 'sass-rails'
gem "susy"
gem 'uglifier'
gem 'refills'
gem "autoprefixer-rails"

# jQuery is the default JavaScript library in Rails 3.1
gem 'jquery-rails'
gem "jquery-ui-rails"

gem "foreman"
gem "haml"
gem "geokit"
gem "nokogiri"
gem 'httparty'
gem "will_paginate"
gem "rails_autolink"
# For minifying javascript and css
#gem 'smurf'
gem 'thinking-sphinx'
gem "formtastic"
gem 'validates_email_format_of', '~> 1.6', '>= 1.6.3'
gem "geocoder"
# Rails 4 support is a work in progress so requires tracking master
gem 'activeadmin', '~> 1.0.0.pre2'
gem "devise"
# Disabling metric_fu because it depends on rcov which doesn't work on Ruby 1.9
#gem 'metric_fu'
gem "rake"
gem 'rack-throttle'
gem 'dalli'
# TODO: move to new Rails santizer, this will be depreciated in Rails 5
#       see http://edgeguides.rubyonrails.org/4_2_release_notes.html#html-sanitizer
gem 'rails-deprecated_sanitizer'
gem 'sanitize'
gem 'vanity'
gem 'rabl'
gem 'newrelic_rpm'
gem 'delayed_job_active_record'
gem 'daemons'
gem "validate_url"
gem "twitter"
gem "atdis"
gem "oj"
gem "redcarpet"
gem 'honeybadger'
gem 'stripe'
gem 'dotenv-rails'
gem 'climate_control'
gem 'everypolitician-popolo', git: 'https://github.com/everypolitician/everypolitician-popolo.git', branch: 'master'
# Using master until an updated version of the Gem is released https://github.com/ciudadanointeligente/writeit-rails/issues/4
gem 'writeit-rails', git: 'https://github.com/ciudadanointeligente/writeit-rails.git', branch: 'master'

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'factory_girl'
  gem 'email_spec', '~> 1.6'
  gem 'coveralls', :require => false
  gem 'vcr', '~> 2.9'
  gem 'webmock'
  gem 'timecop'
  gem 'stripe-ruby-mock', '~> 2.1.1', require: 'stripe_mock'
end

group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'growl'
  gem 'rb-inotify', require: false
  gem 'rack-livereload'
  gem 'mailcatcher'
  gem 'rb-fsevent'
  gem 'rvm-capistrano'
  gem "capistrano"
  gem "better_errors"
  gem "binding_of_caller"
  gem "spring"
  gem "spring-commands-rspec"
  # FIXME: stop using `mock_model` and remove this
  gem "rspec-activemodel-mocks"
end

group :test, :development do
  gem 'rspec-rails', '~> 3'
end

group :production do
  # Javascript runtime (required for precompiling assets in production)
  gem 'therubyracer'
end
