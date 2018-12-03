source 'http://rubygems.org'

ruby '2.2.3'
gem 'rails', '~> 4'
gem 'pg', '~> 0.20.0'
gem 'puma'
gem 'dotenv-rails'
gem "haml-rails", "~> 0.9"
gem 'activerecord-session_store' # store sessions in db rather than in cookies
gem 'syck' # Support for syck. Syck was removed from the ruby stdlib.
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'
gem 'rollbar'

# pagination & tagging
gem "kaminari", "~> 0.15.1"
gem 'will_paginate', "~> 3.0.pre2"
gem 'acts-as-taggable-on'

# Emails
gem 'actionmailer-with-request', '~> 0.3'
gem 'exception_notification' , '~> 4'

# Security
gem 'authlogic'
gem 'rubycas-client', "~> 2.3.9", :require => ['casclient', 'casclient/frameworks/rails/filter']
gem 'ucb_ldap', '>=3.1.1'
gem 'omniauth'
gem 'omniauth-cas'
gem 'bcrypt'

# Misc
gem 'pothoven-attachment_fu'
gem 'nokogiri'
gem 'email_validator'

# Development
group :development do
  gem 'yard'
  gem 'better_errors', "1.1.0"
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'annotate'
  gem 'byebug'
end

# Testing
group :test do
  gem 'autotest-rails'
  gem 'cucumber-rails', "~> 1.4.2"
  gem 'capybara'
  gem 'database_cleaner'
  gem 'simplecov'
end

# Testing or Development
group :test, :development do
  gem 'rspec-rails', '~>3.0'
  gem 'rspec', '~> 3.3'
  gem 'factory_bot_rails', "~> 4.0"
  gem 'derailed_benchmarks'
  gem 'stackprof'
end

# UI
gem 'therubyracer'
gem 'uglifier'
gem 'sass-rails', '>= 3.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-sass', '~> 3.3.3'
gem 'bootstrap_form'
gem 'bootstrap-material-design'

gem 'jquery-datatables-rails', '~> 3.3.0'
gem 'will_paginate-bootstrap'
gem 'bootstrap-datepicker-rails'
gem 'momentjs-rails'
