require 'uri'
require 'net/http'

class Tracker
  def initialize(url)
    @url = url
  end

  def service_up?
    get_response_code == '200'
  end

  private

  def get_response_code
    uri = URI(@url)
    response = Net::HTTP.get_response(uri)
    response.code
  end
end

class TrackerService
  def initialize(storage)
    @storage = storage
  end

  def run
    trackers = @storage.all_trackers
    trackers.each do |tuple|
      tracker_id = tuple['id']
      url = tuple['url']
      tracker = Tracker.new(url)
      query_result = tracker.service_up?
      @storage.add_query_record(query_result, tracker_id)
    end
  end

  # def stop

  # end
end