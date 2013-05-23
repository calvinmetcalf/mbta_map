-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_maps project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

  SELECT SQL_BIG_RESULT z.origin AS origin, z.dest as dest, y.route_id AS route_id, y.route_name AS route_name, y.route_type AS route_type, COUNT(z.dest) AS count_trips
  FROM
  (
    SELECT a.stop_id AS origin, b.stop_id AS dest, a.trip_mysqlid AS trip_mysqlid, b.stop_sequence AS dest_sequence, TIMEDIFF(b.arrival_time, a.departure_time) AS travel_time_secs
    FROM
    (
      SELECT a1.stop_id AS stop_id, a1.departure_time AS departure_time, a1.trip_id AS trip_id, a1.stop_sequence AS stop_sequence, a2.mysql_id AS trip_mysqlid
      FROM
      (
        SELECT stop_id, departure_time, trip_id, stop_sequence
        FROM mbta_data.sched_stop_times
        WHERE feed_id_last = 1
        AND mysql_id < 1000
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
              monday = 1
              OR tuesday = 1
              OR wednesday = 1
              OR thursday = 1
              OR friday = 1
            )
          )
        )
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
      SELECT b1.stop_id AS stop_id, b1.arrival_time AS arrival_time, b2.trip_id AS trip_id, b1.stop_sequence AS stop_sequence, b2.mysql_id AS trip_mysqlid
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
    ) AS b
    ON (a.trip_mysqlid = b.trip_mysqlid)
    AND (a.stop_sequence < b.stop_sequence)
  ) AS z
  LEFT JOIN
  (
    SELECT y2.trip_mysqlid AS trip_mysqlid, y1.route_id AS route_id, y1.route_name AS route_name, y1.route_type AS route_type
    FROM
    (
      SELECT route_id, IF(route_short_name = "",route_long_name, CONCAT(route_long_name, ' ', IF(route_type = 3, CONCAT('Bus ', route_short_name), route_short_name))) AS route_name, route_type
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
  WHERE z.dest IS NOT NULL
  GROUP BY z.origin, z.dest, y.route_id
