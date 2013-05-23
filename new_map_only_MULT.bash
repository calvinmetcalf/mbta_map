# Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
# It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
# and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
# may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

echo "$(date) $line "  "Seeding best times table with ALL stops as origins"
mysql <./sql_scripts/insert_ALL_stops_as_origins.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log

echo "$(date) $line "  "Inserting walking times. (first pass)"
mysql <./sql_scripts/insert_walking_timesv2.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <./sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Inserting route connection times. (first pass)"
mysql <./sql_scripts/insert_route_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <./sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log

echo "$(date) $line "  "Inserting walking times. (second pass)"
mysql <./sql_scripts/insert_walking_timesv2.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <./sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Inserting route connection times. (second pass)"
mysql <./sql_scripts/insert_route_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <./sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log

echo "$(date) $line "  "Inserting walking times. (third pass)"
mysql <./sql_scripts/insert_walking_timesv2.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <./sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Inserting route connection times. (third pass)"
mysql <./sql_scripts/insert_route_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <./sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log

echo "$(date) $line "  "Inserting walking times. (fourth pass)"
mysql <./sql_scripts/insert_walking_timesv2.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <./sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Inserting route connection times. (fourth pass)"
mysql <./sql_scripts/insert_route_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <./sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log
mysql <./sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ./data/setup.log

echo "$(date) $line "  "Setup concluded.  See ./data/setup.log for details"
echo "$(date) $line "  "Run draw_map.py"