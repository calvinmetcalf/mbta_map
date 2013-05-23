-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

SELECT h.dest_mysqlid, h.total_time, h.trip_count, h.transp_mode, h.route_mysqlid, IF(h.route_short_name = '', h.route_long_name, 
    CONCAT('Bus ', h.route_short_name)) AS route_name, h.dest_name AS dest_name, h.route_color, 
    (360 + DEGREES(ATAN2(h.y, h.x))) MOD 360 AS compass, h.trip_leg, h.start_loc AS start_loc, h.prev_stop_mysqlid, h.immed_prev_stop
FROM
(
  SELECT f.start_loc AS start_loc, g.starting_loc_lat AS starting_loc_lat,
	  g.starting_loc_lon AS starting_loc_lon, f.dest_mysqlid AS dest_mysqlid, 
      f.dest_stop_lat AS dest_stop_lat, f.dest_stop_lon AS dest_stop_lon, 
      f.total_time AS total_time, f.route_mysqlid AS route_mysqlid, 
      f.transp_mode AS transp_mode, f.route_color AS route_color, f.trip_leg AS trip_leg,
      f.route_short_name AS route_short_name, f.route_long_name AS route_long_name, f.trip_count AS trip_count,
      SIN(RADIANS(f.dest_stop_lon - g.starting_loc_lon)) * COS(RADIANS(f.dest_stop_lat)) 
        AS y,  
        COS(RADIANS(g.starting_loc_lat)) * SIN(RADIANS(f.dest_stop_lat)) - SIN(RADIANS(g.starting_loc_lat)) * COS(RADIANS(f.dest_stop_lat)) * COS(RADIANS(f.dest_stop_lon - g.starting_loc_lon)) 
        AS x, f.dest_name AS dest_name, f.prev_stop_mysqlid AS prev_stop_mysqlid, f.immed_prev_stop AS immed_prev_stop
  FROM
  (
    SELECT d.start_loc AS start_loc, d.dest_mysqlid AS dest_mysqlid, d.dest_stop_lat AS dest_stop_lat, d.dest_stop_lon AS dest_stop_lon, d.total_time AS total_time, d.route_mysqlid AS route_mysqlid, d.transp_mode AS transp_mode, d.route_color AS route_color, d.route_short_name AS route_short_name, d.route_long_name AS route_long_name, d.trip_leg, e.trip_count AS trip_count, d.dest_name AS dest_name, d.origin_mysqlid AS prev_stop_mysqlid, e.immed_prev_stop AS immed_prev_stop
    FROM
    (
      SELECT a.start_loc AS start_loc, a.origin_mysqlid AS origin_mysqlid, a.dest_mysqlid AS dest_mysqlid, a.total_time AS total_time, a.mode_route_mysqlid AS route_mysqlid, a.dest_stop_lat AS dest_stop_lat, a.dest_stop_lon AS dest_stop_lon, a.trip_leg AS trip_leg, b.route_type AS transp_mode, b.route_color AS route_color, b.route_short_name AS route_short_name, b.route_long_name AS route_long_name, a.dest_name AS dest_name
      FROM
      (
        SELECT a1.start_loc AS start_loc, a1.origin_mysqlid AS origin_mysqlid, a1.dest_mysqlid AS dest_mysqlid, a1.total_time AS total_time, a1.mode_route_mysqlid AS mode_route_mysqlid, a1.trip_leg AS trip_leg, a2.dest_stop_lat AS dest_stop_lat, a2.dest_stop_lon AS dest_stop_lon, a2.dest_name AS dest_name
        FROM
		(
          SELECT start_mysqlid AS start_loc, origin_mysqlid, dest_mysqlid, total_time, mode_route_mysqlid, trip_leg
          FROM mbta_data.mbta_map_best_times
          WHERE start_mysqlid = %(starting_loc)s
        ) AS a1
        LEFT JOIN
        (
          SELECT mysql_id, stop_lat AS dest_stop_lat, stop_lon AS dest_stop_lon, stop_name AS dest_name
          FROM mbta_data.sched_mapping_stops
        ) AS a2
        ON (a1.dest_mysqlid = a2.mysql_id)
      ) AS a
      LEFT JOIN
      (
        SELECT mysql_id, route_type, route_color, route_short_name, route_long_name
        FROM mbta_data.sched_routes
      ) AS b
      ON (a.mode_route_mysqlid=b.mysql_id)
    ) AS d
    LEFT JOIN
    (
      SELECT origin_mysqlid, dest_mysqlid, trip_count, immed_prev_stop
      FROM mbta_data.mbta_map_weekday_72000
    ) AS e
    ON (d.origin_mysqlid=e.origin_mysqlid)
    AND (d.dest_mysqlid=e.dest_mysqlid)
    AND trip_count IS NOT NULL
  ) AS f
  LEFT JOIN
  (
    SELECT mysql_id, stop_lat AS starting_loc_lat, stop_lon AS starting_loc_lon
    FROM mbta_data.sched_mapping_stops
  ) AS g
  ON (f.start_loc = g.mysql_id)
) AS h
ORDER BY h.transp_mode, h.route_mysqlid, h.total_time