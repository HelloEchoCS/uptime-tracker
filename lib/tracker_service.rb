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
      tracker = Tracker.new(tuple)
      query_result = tracker.service_up?
      @storage.add_query_record(query_result, tracker.id)
    end
  end

  # def stop

  # end
end