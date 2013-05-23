-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

CREATE TABLE sched_feed_info_temp_u (
mysql_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(mysql_id), 
html_file_etag VARCHAR(30) NOT NULL DEFAULT "", KEY(html_file_etag),
html_file_content_length INT UNSIGNED, KEY(html_file_content_length),
timestamp TIMESTAMP
);
