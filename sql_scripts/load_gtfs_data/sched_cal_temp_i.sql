-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

CREATE TABLE sched_cal_temp_i (
mysql_id INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(mysql_id), 
service_id VARCHAR(200) NOT NULL, KEY(service_id), 
monday TINYINT UNSIGNED NOT NULL, KEY(monday), 
tuesday TINYINT UNSIGNED NOT NULL, KEY(tuesday), 
wednesday TINYINT UNSIGNED NOT NULL, KEY(wednesday), 
thursday TINYINT UNSIGNED NOT NULL, KEY(thursday), 
friday TINYINT UNSIGNED NOT NULL, KEY(friday), 
saturday TINYINT UNSIGNED NOT NULL, KEY(saturday), 
sunday TINYINT UNSIGNED NOT NULL, KEY(sunday), 
start_date DATE NOT NULL, KEY(start_date),  
end_date DATE NOT NULL, KEY(end_date), 
timestamp TIMESTAMP, 
feed_id_first SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_first), 
feed_id_last SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_last), 
data_hash BINARY(16), KEY(data_hash), 
UNIQUE KEY(service_id, feed_id_last)
);