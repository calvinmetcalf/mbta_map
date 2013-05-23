-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

CREATE TABLE sched_trips_temp_i (
mysql_id INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(mysql_id), 
route_id VARCHAR(120) NOT NULL, KEY(route_id), 
service_id VARCHAR(200), KEY(service_id), 
trip_id VARCHAR(200), KEY(trip_id), 
trip_headsign VARCHAR(200), KEY(trip_headsign), 
direction_id VARCHAR(60), 
block_id VARCHAR(60), 
shape_id VARCHAR(60), KEY (shape_id), 
timestamp TIMESTAMP, 
feed_id_first SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_first), 
feed_id_last SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_last), 
data_hash BINARY(16),  KEY(data_hash), 
UNIQUE KEY(trip_id,feed_id_last)
);