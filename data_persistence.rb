require 'pg'

class DataPersistence
  def initialize
    @storage = PG.connect(dbname: 'uptime-tracker')
  end

  def all_trackers
    sql = 'SELECT name, tracker_type FROM trackers;'
    query(sql)
  end

  def add_new_tracker(name, type, url)
    sql = 'INSERT INTO trackers (name, tracker_type, url) VALUES ($1, $2, $3);'
    query(sql, name, type, url)
  end

  private

  def query(sql, *params)
    @storage.exec_params(sql, params)
  end
end