-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

SELECT e.origin_mysqlid AS origin_mysqlid, e.origin_lat AS origin_lat, e.origin_lon AS origin_lon, e.dest_mysqlid AS dest_mysqlid, e.dest_lon AS dest_lon, e.dest_lat AS dest_lat, e.distance AS distance, ROUND(((e.distance / 3.5) * 3600),0)  AS total_time
FROM
(
  SELECT c.origin_mysqlid AS origin_mysqlid, c.origin_lat AS origin_lat, c.origin_lon AS origin_lon, d.dest_mysqlid AS dest_mysqlid, d.dest_lon AS dest_lon, d.dest_lat AS dest_lat, 
  (((ACOS(SIN(c.origin_lat * PI() / 180) * SIN(d.dest_lat * PI() / 180) + COS(c.origin_lat * PI() / 180) * COS(d.dest_lat * PI() / 180) * COS((c.origin_lon - d.dest_lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515)) AS distance
  FROM
  (
    SELECT a.origin_mysqlid, b.origin_lat AS origin_lat, b.origin_lon AS origin_lon
    FROM
    (
      SELECT dest_mysqlid AS origin_mysqlid
      FROM mbta_data.mbta_map_best_times
    ) AS a
    LEFT JOIN
    (
      SELECT mysql_id, stop_lon AS origin_lon, stop_lat AS origin_lat
      FROM mbta_data.sched_stops
    ) AS b
    ON (a.origin_mysqlid = b.mysql_id)
  ) AS c
  LEFT JOIN
  (
    SELECT mysql_id AS dest_mysqlid, stop_lon AS dest_lon, stop_lat AS dest_lat
    FROM mbta_data.sched_stops
  ) AS d
  ON (1=1)
) AS e
WHERE e.distance < 0.75