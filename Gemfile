source 'http://rubygems.org'

gem 'rails', '3.0.9'
gem 'rake', '0.9.2'

gem 'truncate_html'

gem 'pg'
gem 'silent-postgres'
gem 'jquery-rails', '>= 0.2.6'
gem 'web-app-theme', '>= 0.6.2'
gem 'omniauth'
gem 'devise', '>= 1.2.0'
gem 'geocoder'

gem "default_value_for"
gem 'dynamic_form', :git => "git://github.com/joelmoss/dynamic_form.git"

gem 'deep_cloneable'

gem 'fb_graph'

gem 'mini_magick'
gem 'carrierwave'

gem "hiredis", "~> 0.3.1"
gem "redis", "~> 2.2.0", :require => ["redis/connection/hiredis", "redis"]

gem 'resque', :git => "git://github.com/defunkt/resque.git"
gem 'resque-scheduler', :require => ['resque_scheduler']
gem 'json'

group :production, :staging do
  gem 'exception_notification'
end


group :development do
  gem 'thin'
  # Boosts dev server response time significantly but if you have refresh issues, remove this gem
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git', :require => 'rails_development_boost'
end

group :test, :development do
  gem "rspec-rails", "~> 2.6"
  gem 'factory_girl_rails'
end

#gem "meta_where"

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
