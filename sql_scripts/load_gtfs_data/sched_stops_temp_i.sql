-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

CREATE TABLE sched_stops_temp_i (
mysql_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(mysql_id), 
stop_id VARCHAR(120) NOT NULL, KEY(stop_id), 
stop_code VARCHAR(60), 
stop_name VARCHAR(200), 
stop_desc VARCHAR(600), 
stop_lat DECIMAL(10,8) NOT NULL, 
stop_lon DECIMAL(10,8) NOT NULL,  
zone_id VARCHAR(60), 
stop_url VARCHAR(200), 
location_type TINYINT UNSIGNED, 
parent_station VARCHAR(120), 
timestamp TIMESTAMP, 
feed_id_first SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_first), 
feed_id_last SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_last), 
data_hash BINARY(16), KEY(data_hash), 
UNIQUE KEY(stop_id, feed_id_last)
);