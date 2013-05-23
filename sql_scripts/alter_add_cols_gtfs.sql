-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

ALTER TABLE mbta_data.sched_trips ADD COLUMN route_mysqlid INT UNSIGNED, ADD KEY(route_mysqlid);
ALTER TABLE mbta_data.sched_stop_times ADD COLUMN trip_mysqlid INT UNSIGNED, ADD KEY(trip_mysqlid);
ALTER TABLE mbta_data.sched_stop_times ADD COLUMN stop_mysqlid SMALLINT UNSIGNED, ADD KEY(stop_mysqlid);
