-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

INSERT INTO mbta_data.mbta_map_best_times (start_mysqlid, origin_mysqlid, dest_mysqlid, total_time, mode_route_mysqlid, trip_leg)
SELECT DISTINCT f.start_loc AS start_loc, MAX(f.origin_mysqlid) AS origin_mysqlid, f.dest_mysqlid AS dest_mysqlid, f.total_time AS total_time, 0 AS mode_route_mysqlid, MIN(f.trip_leg) AS trip_leg
FROM
(
  SELECT e.start_loc AS start_loc, e.origin_mysqlid AS origin_mysqlid, e.trip_leg AS trip_leg, e.dest_mysqlid AS dest_mysqlid, (ROUND(((e.dist_miles / 2.5) * 3600) + 25, 0)) + e.prior_time AS total_time
  FROM
  (
    SELECT c.start_loc AS start_loc, c.origin_mysqlid AS origin_mysqlid, c.trip_leg AS trip_leg, c.dest_mysqlid AS dest_mysqlid, c.prior_time AS prior_time, c.dist_miles AS dist_miles
    FROM
    (
      SELECT a.start_loc AS start_loc, a.origin_mysqlid, a.trip_leg AS trip_leg, b.dest_mysqlid AS dest_mysqlid, b.dist_miles AS dist_miles, a.total_time AS prior_time
      FROM
      (
        SELECT start_mysqlid AS start_loc, dest_mysqlid AS origin_mysqlid, total_time, (trip_leg + 1) AS trip_leg
        FROM mbta_data.mbta_map_best_times
		WHERE
        (
          mode_route_mysqlid != 0
          OR total_time = 0
        )
      ) AS a
      LEFT JOIN
      (
        SELECT start_mysqlid, dest_mysqlid, dist_miles
        FROM mbta_data.mbta_map_stop_dists
        WHERE dist_miles <= .5
      ) AS b
      ON (a.origin_mysqlid = b.start_mysqlid)
      WHERE b.dest_mysqlid IS NOT NULL
    ) AS c
  ) AS e  
) AS f
WHERE  
(
  NOT EXISTS
  (
    SELECT MIN(total_time) AS min_time
    FROM mbta_data.mbta_map_best_times
    WHERE f.dest_mysqlid = dest_mysqlid
    AND f.start_loc=start_mysqlid
    GROUP BY start_mysqlid, dest_mysqlid
  )
  OR f.total_time <
  (
    SELECT MIN(total_time) AS min_time
    FROM mbta_data.mbta_map_best_times
    WHERE f.dest_mysqlid = dest_mysqlid
    AND f.start_loc=start_mysqlid
    GROUP BY start_mysqlid, dest_mysqlid
  )
)
GROUP BY f.start_loc, f.dest_mysqlid, f.total_time;
