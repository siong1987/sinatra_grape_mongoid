require 'sinatra'

class Web < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end
