# Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
# It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
# and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
# may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

#!/usr/bin/python

from load_new_gtfs import Load_GTFS_Schedules
from sql_login_info import Db_Login_Credentials

credentials_class = Db_Login_Credentials()
credential_list = credentials_class.get_credentials() #!db login [user,pass,hostname,db_name]

load_class = Load_GTFS_Schedules()
load_class.sched_to_temp_tables(credential_list)
load_class.write_temp_scheds_to_perm(credential_list)
load_class.write_origins_dests_table(credential_list)
