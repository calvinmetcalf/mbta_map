-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_maps project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

INSERT INTO mbta_data.mbta_map_best_times (start_mysqlid, origin_mysqlid, dest_mysqlid, total_time, mode_route_mysqlid, trip_leg)
SELECT DISTINCT f.start_loc AS start_loc, MAX(f.origin_mysqlid) AS origin_mysqlid, f.dest_mysqlid AS dest_mysqlid, f.total_time AS total_time, 0 AS mode_route_mysqlid, MIN(f.trip_leg) AS trip_leg
FROM
(
  SELECT e.start_loc AS start_loc, e.origin_mysqlid AS origin_mysqlid, e.trip_leg AS trip_leg, e.dest_mysqlid AS dest_mysqlid, (ROUND(((e.distance / 3.5) * 3600) + 30,0)) + e.prior_time  AS total_time
  FROM
  (
    SELECT c.start_loc AS start_loc, c.origin_mysqlid AS origin_mysqlid, c.trip_leg AS trip_leg, c.origin_lat AS origin_lat, c.origin_lon AS origin_lon, d.dest_mysqlid AS dest_mysqlid, d.dest_lon AS dest_lon, d.dest_lat AS dest_lat, c.prior_time AS prior_time, 
    (((ACOS(SIN(c.origin_lat * PI() / 180) * SIN(d.dest_lat * PI() / 180) + COS(c.origin_lat * PI() / 180) * COS(d.dest_lat * PI() / 180) * COS((c.origin_lon - d.dest_lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515)) AS distance
    FROM
    (
      SELECT a.start_loc AS start_loc, a.origin_mysqlid, a.trip_leg AS trip_leg, b.origin_lat AS origin_lat, b.origin_lon AS origin_lon, a.total_time AS prior_time, b.origin_geo AS origin_geo
      FROM
      (
        SELECT start_mysqlid AS start_loc, dest_mysqlid AS origin_mysqlid, total_time, (trip_leg + 1) AS trip_leg
        FROM mbta_data.mbta_map_best_times
		WHERE
        (
          mode_route_mysqlid != 0
          OR total_time = 0
        )
        AND trip_leg IN (SELECT MAX(trip_leg) FROM mbta_data.mbta_map_best_times)
      ) AS a
      LEFT JOIN
      (
        SELECT mysql_id, stop_lon AS origin_lon, stop_lat AS origin_lat, stop_geo AS origin_geo
        FROM mbta_data.sched_mapping_stops
      ) AS b
      ON (a.origin_mysqlid = b.mysql_id)
    ) AS c
    LEFT JOIN
    (
      SELECT mysql_id AS dest_mysqlid, stop_lon AS dest_lon, stop_lat AS dest_lat, stop_geo as dest_geo
      FROM mbta_data.sched_mapping_stops
    ) AS d
    ON (GLength(LineString(c.origin_geo, d.dest_geo)) <= .04)
    AND (c.origin_mysqlid != d.dest_mysqlid)
  ) AS e
  WHERE e.distance <= .5
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
SHOW WARNINGS;