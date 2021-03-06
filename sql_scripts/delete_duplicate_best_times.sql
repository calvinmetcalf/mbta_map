-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

DELETE a
FROM mbta_data.mbta_map_best_times AS a
INNER JOIN
(
  SELECT start_mysqlid, dest_mysqlid, origin_mysqlid, total_time, MAX(pri) AS max_pri, COUNT(dest_mysqlid) AS count_dest_inst
  FROM mbta_data.mbta_map_best_times
  GROUP BY start_mysqlid, dest_mysqlid
) AS b
ON (a.origin_mysqlid = b.origin_mysqlid)
AND (a.dest_mysqlid = b.dest_mysqlid)
AND (a.start_mysqlid = b.start_mysqlid)
AND (a.total_time = b.total_time)
AND (a.pri = b.max_pri)
WHERE b.count_dest_inst > 1