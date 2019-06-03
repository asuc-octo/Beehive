source 'http://rubygems.org'

ruby '2.5.5'
gem 'rails', '~> 4'
gem 'pg', '~> 0.20.0'
gem 'puma', '~> 3.12'
gem 'dotenv-rails', '~> 2.7'
gem 'haml-rails', '~> 0.9'
gem 'activerecord-session_store', '~> 1.1' # store sessions in db rather than in cookies
gem 'syck', '~> 1.3' # Support for syck. Syck was removed from the ruby stdlib.
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'
gem 'rollbar', '~> 2.16'
gem 'tzinfo-data'

# pagination & tagging
gem 'kaminari', '~> 1.1'
gem 'will_paginate', '~> 3.0'
gem 'acts-as-taggable-on', '>= 4.0'

# Emails
gem 'actionmailer-with-request', '~> 0.3'
gem 'exception_notification' , '~> 4.2'

# Security
gem 'authlogic', '~> 4.4'
gem 'ucb_ldap', '~> 3.1'
gem 'omniauth', '~> 1.8'
gem 'omniauth-cas', '~> 1.1'
gem 'bcrypt', '~> 3.1'

# Misc
gem 'pothoven-attachment_fu'
gem 'nokogiri'
gem 'email_validator'

# Development
group :development do
  gem 'yard'
  gem 'better_errors', '1.1.0'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'annotate'
  gem 'byebug'
  gem 'letter_opener'
end

# Testing
group :test do
  gem 'autotest-rails'
  gem 'cucumber-rails', '>= 1.7.0'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'simplecov'
end

# Testing or Development
group :test, :development do
  gem 'rspec-rails', '>= 3.0'
  gem 'rspec', '>= 3.3'
  gem 'factory_bot_rails', '>= 4.10'
  gem 'derailed_benchmarks'
  gem 'stackprof'
end

# UI
# gem 'therubyracer'
gem 'uglifier'
gem 'sass-rails', '>= 3.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'bootstrap_form'
gem 'bootstrap-material-design'

gem 'jquery-datatables-rails', '~> 3.3.0'
gem 'will_paginate-bootstrap', '~> 1.0'
gem 'bootstrap-datepicker-rails', '~> 1.8'
gem 'momentjs-rails', '~> 2.20'
