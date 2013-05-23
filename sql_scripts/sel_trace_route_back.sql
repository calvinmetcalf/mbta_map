-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

SELECT a.origin_mysqlid, a.dest_mysqlid, b.stop_name, b.stop_id, a.total_time, a.mode_route_mysqlid, a.trip_leg
FROM
(
  SELECT *
  FROM mbta_map_best_times
  WHERE dest_mysqlid = '6167'
) AS a
LEFT JOIN
(
  SELECT mysql_id, stop_id, stop_name
  FROM mbta_data.sched_stops
) AS b
ON (a.dest_mysqlid = b.mysql_id)