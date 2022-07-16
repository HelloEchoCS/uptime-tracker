require 'pg'

class DataPersistence
  def initialize
    @db = if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: 'uptime-tracker')
    end
  end

  def all_trackers_with_status
    sql = <<~SQL
      SELECT id, name, tracker_type, run_status,
        ( SELECT tracker_status FROM queries
          WHERE trackers.id = queries.tracker_id
          ORDER BY query_time DESC
          LIMIT 1 ) AS tracker_status,
        ( SELECT round((SELECT count(id) FROM queries WHERE queries.tracker_id = trackers.id AND queries.tracker_status = 'Up')/count(id)::numeric * 100, 1)
          FROM queries
          WHERE queries.tracker_id = trackers.id) AS percentage
      FROM trackers ORDER BY id;
    SQL
    query(sql)
  end

  def all_trackers
    sql = 'SELECT * FROM trackers;'
    query(sql)
  end

  def get_tracker_data(tracker_id)
    sql = 'SELECT * FROM trackers WHERE id = $1;'
    query(sql, tracker_id)
  end

  def add_new_tracker(name, type, url)
    sql = 'INSERT INTO trackers (name, tracker_type, url) VALUES ($1, $2, $3);'
    query(sql, name, type, url)
  end

  def add_query_record(query_result, tracker_id)
    sql = 'INSERT INTO queries (tracker_status, tracker_id) VALUES ($1, $2);'
    query(sql, query_result, tracker_id)
  end

  def get_last_created_tracker
    sql = 'SELECT * FROM trackers WHERE id = (SELECT max(id) FROM trackers);'
    query(sql)
  end

  def update_tracker(tracker_id, name, type, url)
    sql = 'UPDATE trackers SET name = $1, tracker_type = $2, url = $3 WHERE id = $4;'
    query(sql, name, type, url, tracker_id)
  end

  def delete_tracker(tracker_id)
    sql = 'DELETE FROM trackers WHERE id = $1;'
    query(sql, tracker_id)
  end

  def pause_tracker(tracker_id)
    sql = "UPDATE trackers SET run_status = 'pause' WHERE id = $1;"
    query(sql, tracker_id)
  end

  def run_tracker(tracker_id)
    sql = "UPDATE trackers SET run_status = 'run' WHERE id = $1;"
    query(sql, tracker_id)
  end

  def disconnect
    @db.close
  end

  private

  def query(sql, *params)
    @db.exec_params(sql, params)
  end
end