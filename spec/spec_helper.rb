ENV["RACK_ENV"] = "test"

require 'bundler/setup'
require './app'
require 'rack/test'

# set :environment, :test

