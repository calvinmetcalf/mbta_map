-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

CREATE TABLE mbta_map_weekday_72000
(
  origin_mysqlid SMALLINT UNSIGNED NOT NULL, 
  dest_mysqlid SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY(origin_mysqlid, dest_mysqlid),
  immed_prev_stop SMALLINT UNSIGNED, KEY(immed_prev_stop),
  avg_travel SMALLINT UNSIGNED NOT NULL,
  std_dev_travel SMALLINT UNSIGNED NOT NULL,
  trip_count SMALLINT UNSIGNED NOT NULL, 
  mode_route_mysqlid INT UNSIGNED, KEY(mode_route_mysqlid),
  count_route_on_pair INT UNSIGNED, KEY(count_route_on_pair)
); 

CREATE TABLE temp_prev_stop_insertions
(
  origin_mysqlid SMALLINT UNSIGNED NOT NULL, 
  dest_mysqlid SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY(origin_mysqlid, dest_mysqlid),
  immed_prev_stop SMALLINT UNSIGNED
); 

CREATE TABLE mbta_map_stop_dists
(
  start_mysqlid SMALLINT UNSIGNED NOT NULL, 
  dest_mysqlid SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY(start_mysqlid, dest_mysqlid),
  dist_miles FLOAT UNSIGNED, KEY(dist_miles)
); 


CREATE TABLE mbta_routes_dest_origin
(
  origin_mysqlid SMALLINT UNSIGNED NOT NULL, 
  dest_mysqlid SMALLINT UNSIGNED NOT NULL,
  route_mysqlid INT UNSIGNED,
  PRIMARY KEY(origin_mysqlid, dest_mysqlid, route_mysqlid),
  count_route_on_pair INT UNSIGNED, KEY(count_route_on_pair)
);

CREATE TABLE mbta_map_best_times
(
  pri INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(pri),
  origin_mysqlid SMALLINT UNSIGNED NOT NULL, 
  start_mysqlid SMALLINT UNSIGNED NOT NULL,
  dest_mysqlid SMALLINT UNSIGNED NOT NULL,
  total_time SMALLINT UNSIGNED NOT NULL,
  mode_route_mysqlid INT UNSIGNED, KEY(mode_route_mysqlid),
  trip_leg TINYINT UNSIGNED, KEY(trip_leg),
  KEY(start_mysqlid, dest_mysqlid, total_time, mode_route_mysqlid, trip_leg)
); 

CREATE TABLE sched_mapping_stops (
mysql_id SMALLINT UNSIGNED NOT NULL, PRIMARY KEY(mysql_id), 
stop_id VARCHAR(120) NOT NULL, KEY(stop_id), 
stop_code VARCHAR(60), 
stop_name VARCHAR(200), 
stop_desc VARCHAR(600), 
stop_lat DECIMAL(10,8) NOT NULL, 
stop_lon DECIMAL(10,8) NOT NULL,  
stop_geo POINT, KEY(stop_geo),
location_type TINYINT UNSIGNED, 
parent_station VARCHAR(120), 
timestamp TIMESTAMP, 
feed_id_first SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_first), 
feed_id_last SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_last), 
data_hash BINARY(16), KEY(data_hash), 
UNIQUE KEY(stop_id, feed_id_last)
);