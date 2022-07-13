require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'

require_relative 'data_persistence'
require_relative 'tracker_service'

configure do
  set :erb, :escape_html => true
  # @tracker_service = TrackerService.new(@storage)
  # @tracker_service.run
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'data_persistence.rb'
  also_reload 'tracker_service.rb'
end

before do
  @storage = DataPersistence.new
end

after do
  # @tracker_service.stop
end

get '/' do
  redirect '/trackers'
end

get '/trackers' do
  @all_trackers = @storage.all_trackers_with_status
  erb :tracker_list, layout: :layout
end

get '/add' do
  erb :add_tracker, layout: :layout
end

post '/save/:id' do
  params[:title] = 'New Tracker'
  tracker_name = params[:tracker_name]
  tracker_type = params[:tracker_type]
  url = params[:url]
  id = params[:id]
  if id
    @storage.update_tracker(id, tracker_name, tracker_type, url)
    result = @storage.get_tracker_data(id.to_i)
  else
    @storage.add_new_tracker(tracker_name, tracker_type, url)
    result = @storage.get_last_created_tracker
  end

  tracker = Tracker.new(result.first)
  query_result = tracker.service_up?
  @storage.add_query_record(query_result, tracker.id)

  redirect '/trackers'
end

get '/edit/:id' do
  result = @storage.get_tracker_data(params[:id].to_i) # to_i?
  tracker = Tracker.new(result.first)
  params[:title] = 'Edit'
  params[:name] = tracker.name
  params[:tracker_type] = tracker.type
  params[:url] = tracker.url

  erb :add_tracker, layout: :layout
end

# get '/debug' do
#   engine = TrackerEngine.new
#   res = engine.send_request('https://www.google.com')
#   res.code
# end