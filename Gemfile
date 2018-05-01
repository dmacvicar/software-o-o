source 'https://rubygems.org'

gem 'nokogiri'
gem 'rails', '~> 5.1.4'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.7'
# With compass
gem 'compass-rails', '~> 3.0.2'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.2.1'

gem 'fast_gettext', '>= 0.7.0'
gem 'gettext_i18n_rails', '>= 0.4.3'

# rails-i18n provides translations for ActiveRecord
# validation error messages
gem 'rails-i18n'

gem 'dalli'
gem 'hashie'
gem 'mini_magick'
gem 'minitest'
gem 'xmlhash', '>= 1.2.2'

gem 'faraday'
gem 'faraday_middleware'
gem 'multi_xml'

# needed to collect translatable strings
# not needed at production
group :development do
  # no need to load the gem via require
  # we only need the rake tasks
  gem 'byebug'
  gem 'gettext', '>= 1.9.3', require: false
  gem 'web-console'
end

group :production do
  gem 'puma'
end

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'rubocop', "~> 0.49.0"
  gem 'webmock'
end

# Debugging gems
gem 'rbtrace', require: false
