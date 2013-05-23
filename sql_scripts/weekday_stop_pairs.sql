-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

INSERT INTO mbta_data.mbta_map_weekday_72000 (origin_mysqlid, dest_mysqlid, avg_travel, std_dev_travel, trip_count)
SELECT SQL_BIG_RESULT z.origin_mysqlid AS origin_mysqlid, z.dest_mysqlid as dest_mysqlid, 
    AVG(TIME_TO_SEC(z.travel_time_secs)) AS avg_travel_time_secs, STD(TIME_TO_SEC(z.travel_time_secs)) AS std_dev_travel_time_secs, 
    COUNT(z.origin_mysqlid) AS trip_count
FROM
(
  SELECT a.origin_mysqlid AS origin_mysqlid, b.dest_mysqlid AS dest_mysqlid, a.trip_mysqlid AS trip_mysql, 
      b.stop_sequence AS dest_sequence, TIMEDIFF(b.arrival_time, a.departure_time) AS travel_time_secs
  FROM
  (
    SELECT a1.origin_mysqlid AS origin_mysqlid, a1.departure_time AS departure_time, a1.trip_id AS trip_id, 
        a1.stop_sequence AS stop_sequence, a2.mysql_id AS trip_mysqlid
    FROM
    (
      SELECT a6.origin_mysqlid AS origin_mysqlid, a5.departure_time AS departure_time, a5.trip_id AS trip_id, 
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
              monday = 1
              OR tuesday = 1
              OR wednesday = 1
              OR thursday = 1
              OR friday = 1
            )
          )
        )
      ) AS a5
      LEFT JOIN
      (
        SELECT mysql_id AS origin_mysqlid, stop_id
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
    SELECT b1.dest_mysqlid AS dest_mysqlid, b1.arrival_time AS arrival_time, b2.trip_id AS trip_id, b1.stop_sequence AS stop_sequence, 
        b2.mysql_id AS trip_mysqlid
    FROM
    (
      SELECT b6.dest_mysqlid AS dest_mysqlid, b5.arrival_time AS arrival_time, b5.trip_id AS trip_id, b5.stop_sequence AS stop_sequence
      FROM
      (
        SELECT stop_id, arrival_time, trip_id, stop_sequence
        FROM mbta_data.sched_stop_times
        WHERE feed_id_last = 1
      ) AS b5
      LEFT JOIN
      (
        SELECT mysql_id AS dest_mysqlid, stop_id
        FROM mbta_data.sched_stops
        WHERE feed_id_last = 1
	  ) AS b6
	  ON (b5.stop_id = b6.stop_id)
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
WHERE z.dest_mysqlid IS NOT NULL
GROUP BY z.origin_mysqlid, z.dest_mysqlid