-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

UPDATE mbta_data.mbta_map_weekday_72000 AS a
INNER JOIN
mbta_data.temp_prev_stop_insertions AS b
ON (a.origin_mysqlid = b.origin_mysqlid)
AND (a.dest_mysqlid = b.dest_mysqlid)
SET a.immed_prev_stop = b.immed_prev_stop;
SHOW WARNINGS;

