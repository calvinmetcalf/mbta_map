-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

INSERT INTO mbta_data.mbta_map_stop_dists (start_mysqlid, dest_mysqlid, dist_miles)
SELECT DISTINCT f.origin_mysqlid AS origin_mysqlid, f.dest_mysqlid AS dest_mysqlid, f.distance AS distance
FROM
(
  SELECT e.origin_mysqlid AS origin_mysqlid, e.dest_mysqlid AS dest_mysqlid, e.distance AS distance
  FROM
  (
    SELECT c.origin_mysqlid AS origin_mysqlid, c.origin_lat AS origin_lat, c.origin_lon AS origin_lon, d.dest_mysqlid AS dest_mysqlid, d.dest_lon AS dest_lon, d.dest_lat AS dest_lat, 
    (((ACOS(SIN(c.origin_lat * PI() / 180) * SIN(d.dest_lat * PI() / 180) + COS(c.origin_lat * PI() / 180) * COS(d.dest_lat * PI() / 180) * COS((c.origin_lon - d.dest_lon) * PI() / 180)) * 180 / PI()) * 60 * 1.1515)) AS distance
    FROM
    (
      SELECT b.mysql_id AS origin_mysqlid, b.origin_lat AS origin_lat, b.origin_lon AS origin_lon, b.origin_geo AS origin_geo
      FROM
      (
        SELECT mysql_id, stop_lon AS origin_lon, stop_lat AS origin_lat, stop_geo AS origin_geo
        FROM mbta_data.sched_mapping_stops
      ) AS b
    ) AS c
    LEFT JOIN
    (
      SELECT mysql_id AS dest_mysqlid, stop_lon AS dest_lon, stop_lat AS dest_lat, stop_geo as dest_geo
      FROM mbta_data.sched_mapping_stops
    ) AS d
    ON (GLength(LineString(c.origin_geo, d.dest_geo)) <= .1)
    AND (c.origin_mysqlid != d.dest_mysqlid)
  ) AS e
  WHERE e.distance <= 1
) AS f
GROUP BY f.origin_mysqlid, f.dest_mysqlid, f.distance;
SHOW WARNINGS;