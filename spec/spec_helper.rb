ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'database_cleaner'
require 'rack/test'

require './config/application'
require './app/api'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
