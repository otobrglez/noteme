require './app'
require 'rack/cors'

use Rack::Cors do
    allow do
      origins '*'
      resource '/*', :headers => :any, :methods => [:get, :post, :options, :put]
      resource '/notes/*', :headers => :any, :methods => [:get, :post, :options, :put]
    end
end

run App
