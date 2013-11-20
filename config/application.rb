require 'uri'
require 'mongoid'
require 'yaml'
require 'erb'
require 'sinatra'
require 'grape'
require 'grape_entity'

Mongoid.load!('./config/mongoid.yml', Sinatra::Base.environment)

# all the tables
require './app/models/event'