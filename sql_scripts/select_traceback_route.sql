-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

SELECT DISTINCT a.immed_prev_stop, a.dest_route_type, b.immed_prev_route_type, b.dest_mysqlid, b.total_time, a.origin_mysqlid, a.mode_route_mysqlid
FROM 
(
  SELECT a1.immed_prev_stop, a1.origin_mysqlid, a2.dest_route_type, a1.mode_route_mysqlid
  FROM 
  (
    SELECT dest_mysqlid, origin_mysqlid, immed_prev_stop, mode_route_mysqlid
    FROM mbta_data.mbta_map_weekday_72000
    WHERE dest_mysqlid = %(immed_prev_mysqlid)s
    AND origin_mysqlid = %(origin_mysqlid)s
  ) AS a1
  LEFT JOIN
  (
  SELECT mysql_id AS route_mysqlid, route_type AS dest_route_type
  FROM mbta_data.sched_routes
  ) AS a2
  ON (a1.mode_route_mysqlid = a2.route_mysqlid)
) AS a
LEFT JOIN
(
  SELECT b1.origin_mysqlid_2, b1.dest_mysqlid, b1.total_time, b2.immed_prev_route_type
  FROM
  (
    SELECT dest_mysqlid, origin_mysqlid AS origin_mysqlid_2, start_mysqlid, total_time, mode_route_mysqlid
    FROM mbta_data.mbta_map_best_times
    WHERE start_mysqlid = %(start_mysqlid)s
  ) AS b1
  LEFT JOIN
  (
  SELECT mysql_id AS route_mysqlid, route_type AS immed_prev_route_type
  FROM mbta_data.sched_routes
  ) AS b2
  ON (b1.mode_route_mysqlid = b2.route_mysqlid)
) AS b
ON (a.dest_route_type = b.immed_prev_route_type OR b.immed_prev_route_type IS NULL)
AND (a.immed_prev_stop = b.dest_mysqlid)
ORDER BY b.total_time
LIMIT 0,1