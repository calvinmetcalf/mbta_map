-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

CREATE TABLE sched_shapes_temp_i (
mysql_id INT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(mysql_id), 
shape_id VARCHAR(60), KEY (shape_id), 
shape_pt_lat DECIMAL(12,10) NOT NULL, 
shape_pt_lon DECIMAL(12,10) NOT NULL, 
shape_pt_sequence INT NOT NULL, 
shape_dist_traveled INT, 
timestamp TIMESTAMP, 
feed_id_first SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_first), 
feed_id_last SMALLINT UNSIGNED NOT NULL DEFAULT 1, KEY (feed_id_last), 
data_hash BINARY(16),  KEY(data_hash)
);