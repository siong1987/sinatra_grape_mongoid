require './config/application'

require './app/api'
require './app/web'

run Rack::Cascade.new [API, Web]
