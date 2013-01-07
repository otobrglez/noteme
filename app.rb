# By Oto Brglez - <oto.brglez@dlabs.si>

require 'bundler/setup'
require 'active_record'
require 'json'
require 'grape'
require 'pp'
require 'rack/cors'

ENV["RACK_ENV"] ||= "development"

class Note < ActiveRecord::Base
  self.include_root_in_json = false
  validates_presence_of :content
  validates_inclusion_of :completed, :in => [0,1]
end

class App < Grape::API

  format :json
  # before do
  #   header "Access-Control-Allow-Origin", "*"
  #   header 'Access-Control-Allow-Credentials', "false"
  #   header 'Access-Control-Allow-Origin', request.env['HTTP_ORIGIN']
  #   header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS'
  #   header 'Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  # end

  get '/' do
    content_type "text/html"
    "<pre>This is noteme by Oto Brglez.

GET     /notes        - List all notes
POST    /notes        - Create new note
                        Structure of note
                          content [text]
                          completed [0 or 1]
PUT     /notes/:id    - Update note with new attributes
DELETE  /notes/:id    - Delete single note
    </pre>"
  end

  get '/origin' do
    content_type "text/html"
    pp request
    "HTTP_ORIGIN: #{request.env['HTTP_ORIGIN']}"
  end

  rescue_from ActiveRecord::RecordInvalid do |invalid|
    errors = []
    invalid.record.errors.each do |att, array|
      errors.push({:"#{att}" => array})
    end
    Rack::Response.new({:errors => errors}.to_json, 400)
  end

  resource :notes do
    get { @notes = Note.all }
    get ':id' do Note.find(params[:id]); end
    post { Note.create!(params[:note]) }
    put ':id' do
      Note.update(params[:id],params[:note])
    end
    delete ':id' do Note.find(params[:id]).destroy; end
  end
end

# Database setup
ActiveRecord::Base.establish_connection('sqlite3:///db/dev-base.sqlite') if ENV["RACK_ENV"] == "development"
ActiveRecord::Base.establish_connection('sqlite3:///db/test-base.sqlite') if ENV["RACK_ENV"] == "test"
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"]) if ENV["RACK_ENV"] == "production"

# Logger setup.
logger = Logger.new(STDOUT)
logger.level = Logger::WARN
ActiveRecord::Base.logger = logger
