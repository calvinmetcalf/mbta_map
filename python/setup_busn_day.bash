# Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
# It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
# and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
# may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

echo 'Welcome to the mbta_map setup script'
echo 'This will take a really long time'
echo 'If that is not ok ... too bad, I don''t know how to give you a way to cancel'
echo 'Sorry.  See ./data/setup.log in about eight hours to find out if this procedure worked.'
echo ''

echo "$(date) $line "  "Performing gfts setup (in common with mbta_ontime setup"
mysql <../sql_scripts/create_gtfs_tables -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
python setup.py
mysql <../sql_scripts/alter_add_cols_gtfs.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log

echo "$(date) $line "  "Dropping map tables."
mysql <../sql_scripts/drop_map_tables.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Creating new map tables."
mysql <../sql_scripts/create_map_tables.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Initializing trip pairs table."
mysql <../sql_scripts/weekday_stop_pairs.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Creating temp table with previous stops for all trip pairs."
mysql <../sql_scripts/weekday_route_pair_counts.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Updating routes and counts into permanent table."
mysql <../sql_scripts/update_orig_dest_w_routes.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Inserting immediate previous stops into temp table."


mysql <../sql_scripts/orig_dest_pairs_add_prev_stopv2.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Moving temp table previous stops to composite table."
mysql <../sql_scripts/update_map_intermed_w_prev_stops.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log

echo "$(date) $line "  "Creating spatially-optimized stops table."
mysql <../sql_scripts/optimized_stops_table.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log

echo "$(date) $line "  "Creating table of distances between stops."
mysql <../sql_scripts/insert_setup_stop_dists.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log


echo "$(date) $line "  "HERE WE GO!"
echo "$(date) $line "  "Seeding best times table with ALL major stops as origin"
mysql <../sql_scripts/insert_ALL_stops_as_origins.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log

echo "$(date) $line "  "Inserting walking times. (first pass)"
mysql <../sql_scripts/insert_walking_timesv2.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <../sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Inserting route connection times. (first pass)"
mysql <../sql_scripts/insert_route_times.sql -u mbta_ontime mbta_data -t -vvv > ../data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <../sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv > ../data/setup.log
mysql <../sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log

echo "$(date) $line "  "Inserting walking times. (second pass)"
mysql <../sql_scripts/insert_walking_timesv2.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <../sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Inserting route connection times. (second pass)"
mysql <../sql_scripts/insert_route_times.sql -u mbta_ontime mbta_data -t -vvv > ../data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <../sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv > ../data/setup.log
mysql <../sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log

echo "$(date) $line "  "Inserting walking times. (third pass)"
mysql <../sql_scripts/insert_walking_timesv2.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <../sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Inserting route connection times. (third pass)"
mysql <../sql_scripts/insert_route_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo 'Deleting non-best times from table.'
mysql <../sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log

echo "$(date) $line "  "Inserting walking times. (fourth pass)"
mysql <../sql_scripts/insert_walking_timesv2.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Deleting non-best times from table."
mysql <../sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Inserting route connection times. (fourth pass)"
mysql <../sql_scripts/insert_route_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo 'Deleting non-best times from table.'
mysql <../sql_scripts/delete_non_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_duplicate_best_times.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
mysql <../sql_scripts/delete_dests_where_origin_deleted.sql -u mbta_ontime mbta_data -t -vvv >> ../data/setup.log
echo "$(date) $line "  "Setup concluded.  See ./data/setup.log for details"
echo "Run draw_map.py"