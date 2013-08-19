require 'uri'
require 'active_record'
require 'yaml'
require 'erb'

# Sets up database configuration
db = URI.parse(ENV['DATABASE_URL']) if ENV['DATABASE_URL']
if db && db.scheme == 'postgres' # Heroku environment
  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1]
  )
else # local environment
  environment = ENV['RACK_ENV'] || 'development'
  db = YAML.load(ERB.new(File.read('config/database.yml')).result)[environment]
  ActiveRecord::Base.establish_connection(db)
end
