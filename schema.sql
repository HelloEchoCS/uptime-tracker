CREATE TABLE trackers (
  id serial PRIMARY KEY,
  name text NOT NULL,
  tracker_type text NOT NULL,
  url text NOT NULL
);

CREATE TABLE queries (
  id serial PRIMARY KEY,
  query_time timestamp NOT NULL,
  success boolean NOT NULL,
  tracker_id integer NOT NULL REFERENCES trackers(id) ON DELETE CASCADE
);