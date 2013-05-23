-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

DELETE a
FROM mbta_data.mbta_map_best_times AS a
LEFT JOIN
(
  SELECT start_mysqlid, dest_mysqlid, trip_leg
  FROM mbta_data.mbta_map_best_times
) AS b
ON (a.origin_mysqlid = b.dest_mysqlid)
AND (a.start_mysqlid = b.start_mysqlid)
AND (a.trip_leg - 1 = b.trip_leg)
WHERE b.dest_mysqlid IS NULL
AND a.origin_mysqlid IS NOT NULL
AND a.origin_mysqlid != 0
;