-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

  INSERT INTO mbta_data.mbta_routes_dest_origin (origin_mysqlid, dest_mysqlid, route_mysqlid, count_route_on_pair)
  SELECT SQL_BIG_RESULT z.origin_mysqlid AS origin_mysqlid, z.dest_mysqlid as dest_mysqlid, y.route_mysqlid AS route_mysqlid, 
      COUNT(z.dest_mysqlid) AS count_trips
  FROM
  (
    SELECT a.origin_mysqlid AS origin_mysqlid, b.dest_mysqlid AS dest_mysqlid, a.trip_mysqlid AS trip_mysqlid, 
        b.stop_sequence AS dest_sequence, TIMEDIFF(b.arrival_time, a.departure_time) AS travel_time_secs
    FROM
    (
      SELECT a1.origin_mysqlid AS origin_mysqlid, a1.departure_time AS departure_time, a1.trip_id AS trip_id, 
          a1.stop_sequence AS stop_sequence, a2.mysql_id AS trip_mysqlid
      FROM
      (
        SELECT a6.stop_mysqlid AS origin_mysqlid, a5.departure_time AS departure_time, a5.trip_id AS trip_id, 
            a5.stop_sequence AS stop_sequence
        FROM
        (
          SELECT stop_id, departure_time, trip_id, stop_sequence
          FROM mbta_data.sched_stop_times
          WHERE feed_id_last = 1
          AND trip_id IN
          (
            SELECT trip_id 
            FROM mbta_data.sched_trips
            WHERE feed_id_last = 1
            AND service_id IN
            (
              SELECT service_id 
              FROM mbta_data.sched_cal
              WHERE feed_id_last = 1
              AND
              (
                saturday = 1
              )
            )
          )
	    ) AS a5
        LEFT JOIN
        (
          SELECT mysql_id AS stop_mysqlid, stop_id
          FROM mbta_data.sched_stops
          WHERE feed_id_last = 1
		) AS a6
        ON (a5.stop_id = a6.stop_id)
	  ) AS a1
      LEFT JOIN
      (
        SELECT mysql_id, trip_id
        FROM mbta_data.sched_trips
      ) AS a2
      ON (a1.trip_id = a2.trip_id)
    ) AS a
    LEFT JOIN
    (
      SELECT bb.stop_mysqlid AS dest_mysqlid, b5.arrival_time AS arrival_time, b5.trip_id AS trip_id, b5.stop_sequence AS stop_sequence, 
          b5.trip_mysqlid AS trip_mysqlid
      FROM
      (
        SELECT b1.stop_id AS stop_id, b1.arrival_time AS arrival_time, b2.trip_id AS trip_id, b1.stop_sequence AS stop_sequence, 
            b2.mysql_id AS trip_mysqlid
        FROM
        (
          SELECT stop_id, arrival_time, trip_id, stop_sequence
          FROM mbta_data.sched_stop_times
          WHERE feed_id_last = 1
        ) AS b1
        LEFT JOIN
        (
          SELECT mysql_id, trip_id
          FROM mbta_data.sched_trips
        ) AS b2
        ON (b1.trip_id = b2.trip_id)
      ) AS b5
      LEFT JOIN
      (
        SELECT mysql_id AS stop_mysqlid, stop_id
        FROM mbta_data.sched_stops
        WHERE feed_id_last = 1
      ) AS bb
      ON b5.stop_id = bb.stop_id
    ) AS b
    ON (a.trip_mysqlid = b.trip_mysqlid)
    AND (a.stop_sequence < b.stop_sequence)
  ) AS z
  LEFT JOIN
  (
    SELECT y2.trip_mysqlid AS trip_mysqlid, y1.route_mysqlid AS route_mysqlid
    FROM
    (
      SELECT mysql_id AS route_mysqlid, route_id
      FROM mbta_data.sched_routes
      WHERE feed_id_last = 1
    ) AS y1
    RIGHT JOIN
    (
      SELECT mysql_id AS trip_mysqlid, route_id
      FROM mbta_data.sched_trips
      WHERE feed_id_last = 1
    ) AS y2
    ON y2.route_id=y1.route_id
  ) AS y
  ON z.trip_mysqlid = y.trip_mysqlid
  WHERE z.dest_mysqlid IS NOT NULL
  AND y.trip_mysqlid IS NOT NULL
  GROUP BY z.origin_mysqlid, z.dest_mysqlid, y.route_mysqlid;

  SHOW WARNINGS;