require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'

require_relative 'data_persistence'
require_relative 'tracker_engine'

configure do
  set :erb, :escape_html => true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'database_persistence.rb'
end

before do
  @storage = DataPersistence.new
  # @tracker_service = TrackerOrchestration.new
  # @tracker_service.run
end

after do
  # @tracker_service.stop
end

get '/' do
  redirect '/trackers'
end

get '/trackers' do
  @all_trackers = @storage.all_trackers
  erb :tracker_list, layout: :layout
end

get '/add' do
  erb :add_tracker, layout: :layout
end

post '/add' do
  tracker_name = params[:tracker_name]
  tracker_type = params[:tracker_type]
  url = params[:url]
  @storage.add_new_tracker(tracker_name, tracker_type, url)

  redirect '/trackers'
end

# get '/debug' do
#   engine = TrackerEngine.new
#   res = engine.send_request('https://www.google.com')
#   res.code
# end