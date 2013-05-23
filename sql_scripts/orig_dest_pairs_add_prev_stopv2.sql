-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

INSERT INTO temp_prev_stop_insertions (origin_mysqlid, dest_mysqlid, immed_prev_stop)
SELECT DISTINCT i.origin, i.dest, MIN(i.prev_mysqlid)
FROM
(
  SELECT h.origin, h.dest, h.route, h.prev_mysqlid, h.count_inst, MAX(h.count_inst) AS max_count_inst
  FROM
  (
    SELECT DISTINCT f.origin, f.dest, f.route, g.prev_mysqlid, COUNT(f.origin) AS count_inst
    FROM
    (
      SELECT d.origin, d.dest, d.route, d.orig_seq, d.trip_mysqlid, e.dest_seq, (e.dest_seq - 1) AS prev_seq
      FROM
      (
        SELECT a.origin, a.dest, a.route, b.orig_seq, b.trip_mysqlid
        FROM
        (
          SELECT origin_mysqlid AS origin, dest_mysqlid AS dest, mode_route_mysqlid AS route
          FROM mbta_data.mbta_map_weekday_72000
        ) AS a
        LEFT JOIN
        (
          SELECT d3.stop_sequence AS orig_seq, d3.trip_mysqlid, d3.route_mysqlid, d3.origin_mysqlid
          FROM
          (
            SELECT d1.stop_mysqlid AS origin_mysqlid, d1.stop_sequence, d1.trip_mysqlid, d2.route_mysqlid
            FROM
            (
              SELECT stop_mysqlid, stop_sequence, trip_mysqlid
              FROM mbta_data.sched_stop_times
              WHERE feed_id_last = 1
            ) AS d1
            LEFT JOIN
            (
              SELECT d2a.route_mysqlid, d2b.trip_mysqlid
              FROM
              (
                SELECT mysql_id AS route_mysqlid
                FROM mbta_data.sched_routes
                WHERE feed_id_last = 1
              ) AS d2a
              LEFT JOIN
              (
                SELECT route_mysqlid, mysql_id AS trip_mysqlid
                FROM mbta_data.sched_trips
                WHERE feed_id_last = 1
              ) AS d2b
              ON (d2a.route_mysqlid = d2b.route_mysqlid)
            ) AS d2
            ON (d1.trip_mysqlid = d2.trip_mysqlid)
          ) d3
        ) AS b
        ON (a.origin = b.origin_mysqlid)
        AND (a.route = b.route_mysqlid)
      ) AS d
      LEFT JOIN
      (
        SELECT e3.stop_sequence AS dest_seq, e3.trip_mysqlid, e3.route_mysqlid, e3.dest_mysqlid
        FROM
        (
          SELECT e1.stop_mysqlid AS dest_mysqlid, e1.stop_sequence, e1.trip_mysqlid, e2.route_mysqlid
          FROM
          (
            SELECT stop_mysqlid, stop_sequence, trip_mysqlid
            FROM mbta_data.sched_stop_times
            WHERE feed_id_last = 1
          ) AS e1
          LEFT JOIN
          (
            SELECT e2a.route_mysqlid, e2b.trip_mysqlid
            FROM
            (
              SELECT mysql_id AS route_mysqlid
              FROM mbta_data.sched_routes
              WHERE feed_id_last = 1
            ) AS e2a
            LEFT JOIN
            (
              SELECT route_mysqlid, mysql_id AS trip_mysqlid
              FROM mbta_data.sched_trips
              WHERE feed_id_last = 1
            ) AS e2b
            ON (e2a.route_mysqlid = e2b.route_mysqlid)
          ) AS e2
          ON (e1.trip_mysqlid = e2.trip_mysqlid)
        ) e3
      ) AS e
      ON (d.dest = e.dest_mysqlid)
      AND (d.route = e.route_mysqlid)
      AND (d.trip_mysqlid = e.trip_mysqlid)
      WHERE d.orig_seq < e.dest_seq
    ) AS f
    LEFT JOIN
    (
      SELECT g3.stop_sequence AS prev_seq, g3.trip_mysqlid, g3.route_mysqlid, g3.prev_mysqlid
      FROM
      (
        SELECT g1.stop_mysqlid AS prev_mysqlid, g1.stop_sequence, g1.trip_mysqlid, g2.route_mysqlid
        FROM
        (
          SELECT stop_mysqlid, stop_sequence, trip_mysqlid
          FROM mbta_data.sched_stop_times
          WHERE feed_id_last = 1
        ) AS g1
        LEFT JOIN
        (
          SELECT g2a.route_mysqlid, g2b.trip_mysqlid
          FROM
          (
            SELECT mysql_id AS route_mysqlid
            FROM mbta_data.sched_routes
            WHERE feed_id_last = 1
          ) AS g2a
          LEFT JOIN
          (
            SELECT route_mysqlid, mysql_id AS trip_mysqlid
            FROM mbta_data.sched_trips
            WHERE feed_id_last = 1
          ) AS g2b
          ON (g2a.route_mysqlid = g2b.route_mysqlid)
        ) AS g2
        ON (g1.trip_mysqlid = g2.trip_mysqlid)
      ) g3
    ) AS g
    ON (f.route = g.route_mysqlid)
    AND (f.trip_mysqlid = g.trip_mysqlid)
    AND (f.prev_seq = g.prev_seq)
    GROUP BY f.origin, f.dest, f.route, g.prev_mysqlid
  ) AS h
  GROUP BY h.origin, h.dest, h.route, h.prev_mysqlid
) AS i
WHERE i.count_inst = i.max_count_inst
GROUP BY i.origin, i.dest