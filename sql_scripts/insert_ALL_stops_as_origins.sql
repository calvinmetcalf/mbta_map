-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

INSERT INTO `mbta_data`.`mbta_map_best_times` 
    (`start_mysqlid`, `origin_mysqlid`, `dest_mysqlid`, `total_time`, `mode_route_mysqlid`, `trip_leg`) 
SELECT mysql_id, 0, mysql_id, 0, 0, 0
FROM mbta_data.sched_stops
WHERE LEFT(stop_id, 6) = 'place-'
OR mysql_id = 7968;
SHOW WARNINGS;
