require 'pg'

class DataPersistence
  def initialize
    @storage = PG.connect(dbname: 'uptime-tracker')
  end

  def all_trackers_with_status
    sql = <<~SQL
      SELECT id, name, tracker_type,
        ( SELECT success FROM queries
          WHERE trackers.id = queries.tracker_id
          ORDER BY query_time DESC
          LIMIT 1 ) AS tracker_status
      FROM trackers;
    SQL
    query(sql)
  end

  def all_trackers
    sql = 'SELECT * FROM trackers;'
    query(sql)
  end

  def add_new_tracker(name, type, url)
    sql = 'INSERT INTO trackers (name, tracker_type, url) VALUES ($1, $2, $3);'
    query(sql, name, type, url)
  end

  def add_query_record(query_result, tracker_id)
    sql = 'INSERT INTO queries (success, tracker_id) VALUES ($1, $2);'
    query(sql, query_result, tracker_id)
  end

  def get_most_recent_tracker_id
    sql = 'SELECT id FROM trackers ORDER BY id DESC LIMIT 1;'
    result = query(sql)
    result.values.flatten[0]
  end

  private

  def query(sql, *params)
    @storage.exec_params(sql, params)
  end
end