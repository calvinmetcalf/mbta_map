-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

INSERT
INTO mbta_data.trips_origins_dests (trip_mysql_id, trip_id, first_stop_id, first_stop_mysql_id, last_stop_id, last_stop_mysql_id, feed_id_last)
SELECT  nnn.trip_mysql_id AS trip_mysql_id, mmm.trip_id AS trip_id, mmm.first_stop_id AS first_stop_id, mmm.first_stop_mysql_id AS first_stop_mysql_id, mmm.last_stop_id AS last_stop_id, mmm.last_stop_mysql_id AS last_stop_mysql_id, %(cur_feed_id)s
FROM
(
  SELECT qqq.trip_id AS trip_id, qqq.first_stop_id AS first_stop_id, qqq.first_stop_mysql_id AS first_stop_mysql_id, qqq.last_stop_id AS last_stop_id, rrr.last_stop_mysql_id AS last_stop_mysql_id
  FROM
  (
    SELECT ss.trip_id AS trip_id, ss.first_stop_id AS first_stop_id, tt.first_stop_mysql_id AS first_stop_mysql_id, ss.last_stop_id AS last_stop_id
    FROM
    (
      SELECT a.trip_id AS trip_id, a.first_stop_id AS first_stop_id, d.last_stop_id AS last_stop_id
      FROM
      (
        SELECT b.trip_id AS trip_id, c.first_stop_id AS first_stop_id, b.max_seq AS max_seq
        FROM
        (
          SELECT trip_id AS trip_id, MAX(stop_sequence) AS max_seq,
              MIN(stop_sequence) AS min_seq
          FROM mbta_data.sched_stop_times 
          WHERE feed_id_last = %(cur_feed_id)s
          AND trip_id IN
            (
              SELECT trip_id
              FROM mbta_data.sched_trips
              WHERE mysql_id >= %(first_mysql_id)s
              AND mysql_id < %(last_mysql_id)s
              AND feed_id_last = %(cur_feed_id)s
            )
          GROUP BY trip_id
        ) AS b
        LEFT JOIN
        (
          SELECT trip_id, stop_sequence, stop_id AS first_stop_id
          FROM mbta_data.sched_stop_times
          WHERE feed_id_last = %(cur_feed_id)s
        ) AS c
        ON (b.trip_id=c.trip_id) AND (b.min_seq=c.stop_sequence)
      ) AS a
      LEFT JOIN
      (
        SELECT trip_id, stop_sequence, stop_id AS last_stop_id
        FROM mbta_data.sched_stop_times
        WHERE feed_id_last = %(cur_feed_id)s
      ) AS d
      ON (a.trip_id=d.trip_id) AND (a.max_seq=d.stop_sequence)
    ) AS ss
    LEFT JOIN
    (
      SELECT mysql_id AS first_stop_mysql_id, stop_id, feed_id_last
      FROM mbta_data.sched_stops
      WHERE feed_id_last = %(cur_feed_id)s
    ) AS tt
    ON (ss.first_stop_id=tt.stop_id)
  ) AS qqq
  LEFT JOIN
  (
    SELECT mysql_id AS last_stop_mysql_id, stop_id, feed_id_last
    FROM mbta_data.sched_stops
    WHERE feed_id_last = %(cur_feed_id)s
  ) AS rrr
  ON (qqq.last_stop_id=rrr.stop_id)
)  AS mmm
LEFT JOIN
(
  SELECT mysql_id AS trip_mysql_id, trip_id, feed_id_last
  FROM mbta_data.sched_trips
  WHERE feed_id_last = %(cur_feed_id)s
) AS nnn
ON (mmm.trip_id=nnn.trip_id)
;