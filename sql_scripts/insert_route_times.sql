-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

INSERT INTO mbta_data.mbta_map_best_times (start_mysqlid, origin_mysqlid, dest_mysqlid, total_time, mode_route_mysqlid, trip_leg)
SELECT DISTINCT e.start_loc as start_loc, MIN(e.origin_mysqlid), e.dest_mysqlid, e.total_time, 
    MIN(e.mode_route_mysqlid) AS mode_route_mysqlid, MIN(e.trip_leg) AS trip_leg
FROM
(
  SELECT a.start_loc AS start_loc, a.origin_mysqlid AS origin_mysqlid, a.trip_leg AS trip_leg, b.dest_mysqlid AS dest_mysqlid, 
      (a.total_time + b.avg_travel + IF( avg_headway > a.alt_headway, a.alt_headway, avg_headway)) AS total_time, 
      b.mode_route_mysqlid AS mode_route_mysqlid
  FROM
  (
    SELECT start_mysqlid AS start_loc, dest_mysqlid AS origin_mysqlid, total_time, (trip_leg + 1) AS trip_leg, ((2 + (6 * (trip_leg + 1) / 2 ))* 60) AS alt_headway
    FROM mbta_data.mbta_map_best_times
    WHERE trip_leg IN (SELECT MAX(trip_leg) FROM mbta_data.mbta_map_best_times)
  ) AS a
  LEFT JOIN
  (
    SELECT origin_mysqlid, dest_mysqlid, (avg_travel + 25) AS avg_travel, ((72000 / count_route_on_pair) / 2) AS avg_headway, mode_route_mysqlid
    FROM mbta_data.mbta_map_weekday_72000
    WHERE trip_count >= 4
  ) AS b
  ON (a.origin_mysqlid = b.origin_mysqlid)
  AND (a.origin_mysqlid != b.dest_mysqlid)
) AS e
WHERE e.dest_mysqlid IS NOT NULL
AND 
(
  NOT EXISTS
  (
    SELECT MIN(total_time) AS min_time
    FROM mbta_data.mbta_map_best_times
    WHERE e.dest_mysqlid=dest_mysqlid
    AND e.start_loc=start_mysqlid
    GROUP BY start_mysqlid, dest_mysqlid
  )
  OR e.total_time <
  (
    SELECT MIN(total_time) AS min_time
    FROM mbta_data.mbta_map_best_times
    WHERE e.dest_mysqlid=dest_mysqlid
    AND e.start_loc=start_mysqlid
    GROUP BY start_mysqlid, dest_mysqlid
  )
)
GROUP BY e.start_loc, e.dest_mysqlid, e.total_time;
SHOW WARNINGS;