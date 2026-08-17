source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.6'

gem 'rails', '8.1.3.1'
gem 'sqlite3'
gem 'puma', '~> 7.0'
gem 'sprockets-rails'
gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false

gem 'verbal_expressions'
gem 'roo'
gem 'roo-xls'

group :development, :test do
  gem 'byebug', platforms: [:mri, :windows]
end

group :development do
  gem 'rails-erd'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5'
end

group :test do
  gem 'rspec'
end

gem 'tzinfo-data', platforms: [:windows, :jruby]

gem "mail", "= 2.8.1"
