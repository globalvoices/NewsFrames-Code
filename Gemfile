source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

group :development, :test do
  gem 'dotenv-rails', :require => 'dotenv/rails-now'
end

gem 'active_record_union'
gem 'activemodel-serializers-xml'
gem 'custom_error_message'
gem 'devise_invitable'
gem 'devise'
gem 'etherpad-lite'
gem 'globalize-accessors'
gem 'globalize', git: 'https://github.com/globalize/globalize'
gem 'httparty'
gem 'iso-639'
gem 'kaminari'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rails-i18n'
gem 'rails', '5.0.2'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'rolify'
gem 'tinplate'
gem 'validates_email_format_of'
gem 'virtus'

# active admin
gem 'activeadmin', '~> 1.0.0.pre5'
gem 'inherited_resources', '~> 1.7'

# Asset pipeline
gem 'bootstrap-sass'
gem 'devise-bootstrapped'
gem 'autoprefixer-rails'
gem 'jquery-rails'
gem 'sass-rails'
gem "font-awesome-rails"
gem 'uglifier'

# Monitoring
gem 'god'

# Logging
gem 'rollbar'

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'pry-rails'

  # Deployment
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-nvm'
end

group :development, :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
end

group :test do
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
