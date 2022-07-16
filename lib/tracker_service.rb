require 'uri'
require 'net/http'

class Tracker
  attr_reader :id, :url, :type, :name

  def initialize(tuple)
    @url = tuple['url']
    @id = tuple['id']
    @type = tuple['type']
    @name = tuple['name']
  end

  def fetch(uri, limit = 10)
    begin
      response = Net::HTTP.get_response(uri)
    rescue => error
      return error
    end
    if Net::HTTPRedirection === response
      location = URI(response['location'])
      fetch(location, limit - 1)
    else
      response
    end
  end
end

class TrackerService
  def initialize(storage)
    @storage = storage
  end

  def run
    puts 'Tracker Service is running!'
    loop do
      trackers = @storage.all_trackers
      trackers.each do |tuple|
        next if tuple['run_status'] == 'pause'
        run_once(tuple)
      end
      sleep 60
    end
  end

  def run_once(tuple)
    tracker = Tracker.new(tuple)
    response = tracker.fetch(URI(tracker.url))
    status = determine_status(response)
    @storage.add_query_record(status, tracker.id)
    response
  end

  def determine_status(response)
    case response
    when Net::HTTPSuccess then
      'Up'
    else
      'Down'
    end
  end
end