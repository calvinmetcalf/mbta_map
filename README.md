<!-- # Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project.  -->
<!-- # It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution  -->
<!-- # and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file,  -->
<!-- # may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file. -->

mbta_map
===========

visualizing mbta travel times
for the finished product, see: < http://www.transitboston.com/resources/time_maps/ >

dependencies / requires:
    
    Linux OS / tested and working on OpenSuse 12.3
        might work on other operating systems, but needs postscript ('.ps') support
    
    mysql or mariadb
    mysql connector for python : see http://www.mysql.com/products/connector/
    ImageMagick command line tools ('convert')
    
to begin:

    manually create a mysql database named mbta_data
    
    create a database user 'mbta_ontime@localhost' that has the following permissions:
    GRANT ALL ON mbta_data.* to 'mbta_ontime'@'localhost' WITH GRANT OPTION;

    The batch files are set up for a user with *no* password, so if you use one you will need to edit
    
    create folder './data/' (if not created automatically), and possibly subfolders './data/ps/' and './data/png/'
    
scripts:

    there are three stages of preparation for the data:
        1) loading raw schedules from MassDOT .zip file posted online
        2) averaging route information and calculating walking distances
        3) tracing routes from origins to all destinations, along with times

    these preparations are performed by bash scripts.

    Two scripts in ./python entitled 'setup_' will perform all of the necessary preparations from beginning to end.
    You need only run one of the two.
    The 'setup_' scripts differ in the route information they use.  One uses data from business days (recommended) and
    the other uses data from weekends (not recommended at this time).

    These setup scripts take very long, like half a day.

    Also, some scripts located in the root folder ('./new_map_...') perform only the last preparatory operation (3).
    One must manually delete all records in the mysql table 'mbta_map_best_times' to run the script.
    These scripts are useful for adding start locations or changing assumptions for walk speeds and headways.
    

logs:    
    various logs and diagnostic data are dumped into the folder ./mbta_maps/data/
    
