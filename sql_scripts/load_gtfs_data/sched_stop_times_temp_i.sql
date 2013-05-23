-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

CREATE TABLE sched_stop_times_temp_i (
mysql_id INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(mysql_id), 
trip_id VARCHAR(200) NOT NULL, KEY (trip_id), 
arrival_time TIME NOT NULL, KEY(arrival_time), 
departure_time TIME NOT NULL, KEY(departure_time), 
stop_id VARCHAR(120) NOT NULL, KEY(stop_id), 
stop_sequence TINYINT UNSIGNED NOT NULL, KEY(stop_sequence), 
stop_headsign VARCHAR(60), 
pickup_type TINYINT UNSIGNED NOT NULL, 
drop_off_type TINYINT UNSIGNED NOT NULL,
timestamp TIMESTAMP, 
feed_id_first SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_first), 
feed_id_last SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_last), 
data_hash BINARY(16), KEY(data_hash), 
KEY (mysql_id, stop_sequence)
);