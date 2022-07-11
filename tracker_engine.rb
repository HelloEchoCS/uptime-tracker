require 'uri'
require 'net/http'

class TrackerEngine
  def get_response_code(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    response.code
  end
end

class TrackerOrchestration
  def initialize(storage)
    @storage = storage
  end

  def run_once
    engine = TrackerEngine.new
    # @storage.all_trackers.each
    @storage.add_query_record if engine.get_response_code(url) == 200
  end

  def stop

  end
end