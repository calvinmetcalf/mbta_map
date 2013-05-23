-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

UPDATE mbta_data.mbta_map_weekday_72000 AS a,
mbta_data.mbta_routes_dest_origin AS b
SET a.mode_route_mysqlid = b.route_mysqlid, 
    a.count_route_on_pair = b.count_route_on_pair
WHERE (a.origin_mysqlid = b.origin_mysqlid)
AND (a.dest_mysqlid = b.dest_mysqlid);
SHOW WARNINGS;

