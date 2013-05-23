-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

UPDATE mbta_data.sched_trips AS a
INNER JOIN
mbta_data.sched_routes AS b
ON (a.route_id = b.route_id)
SET a.route_mysqlid = b.mysql_id;