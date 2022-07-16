require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'

require_relative 'lib/data_persistence'
require_relative 'lib/tracker_service'

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
  @storage = DataPersistence.new
  @tracker_service = TrackerService.new(@storage)
  Thread.abort_on_exception = true
  Thread.new { @tracker_service.run }
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'lib/data_persistence.rb'
  also_reload 'lib/tracker_service.rb'
end

before do
  @storage = DataPersistence.new
end

after do
  @storage.disconnect
end

helpers do
  def determine_run_pause(run_status)
    return 'run' if run_status == 'pause'
    'pause'
  end
end

get '/' do
  redirect '/trackers'
end

get '/trackers' do
  @all_trackers = @storage.all_trackers_with_status
  erb :tracker_list, layout: :layout
end

get '/add' do
  params[:title] = 'New Tracker'
  erb :add_tracker, layout: :layout
end

post '/save' do
  tracker_name = params[:tracker_name]
  tracker_type = params[:tracker_type]
  url = params[:url]
  @storage.add_new_tracker(tracker_name, tracker_type, url)
  result = @storage.get_last_created_tracker

  response = TrackerService.new(@storage).run_once(result.first)

  if Net::HTTPSuccess === response
    session[:success] = "New tracker created. #{response.code} - #{response.message}"
  else
    session[:success] = "New tracker created."
    session[:error] = response.message
  end
  redirect '/trackers'
end

post '/save/:id' do
  tracker_name = params[:tracker_name]
  tracker_type = params[:tracker_type]
  url = params[:url]
  id = params[:id]
  @storage.update_tracker(id, tracker_name, tracker_type, url)
  result = @storage.get_tracker_data(id.to_i)

  response = TrackerService.new(@storage).run_once(result.first)

  if Net::HTTPSuccess === response
    session[:success] = "New tracker created. #{response.code} - #{response.message}"
  else
    session[:success] = "New tracker created."
    session[:error] = response.message
  end

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

post '/delete/:id' do
  @storage.delete_tracker(params[:id].to_i)

  session[:success] = 'Deleted.'

  redirect '/trackers'
end

post '/pause/:id' do
  @storage.pause_tracker(params[:id].to_i)

  session[:success] = 'Paused.'
  redirect '/trackers'
end

post '/start/:id' do
  @storage.start_tracker(params[:id].to_i)

  session[:success] = 'Tracker started.'
  redirect '/trackers'
end