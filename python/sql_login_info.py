# Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
# It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
# and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
# may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

#! /bin/python

import sys
import pickle
import base64

class Db_Login_Credentials:
    
    def __init__(self):
        self.name = 'db_credentials'
        self.object = 'get_credentials'
        
    #! this does the downloading and saving
    def get_credentials(a):

        cfg_path = u'../data/mbta_ontime.cfg'

        write = sys.stdout.write
        loop = True

        try:
            cfg_file = open(cfg_path, 'rb')

            default_info = pickle.load(cfg_file)  #! list [user, pass, host] 
            cfg_file.close()
            if len(default_info) != 5: raise NameError('bad_values')
            write('Found saved database login settings.  Using.  To change settings, delete file ' + cfg_path + ' and restart.\n')

        except:
            while loop == True:
                default_info = [u'mbta_ontime',u'',u'localhost',u'mbta_data',u'user@email']
                write('\nLogin information not located.  Location checked: ' + cfg_path + '\n\n')
                write('Default values:  User:\'' + default_info[0] +  '\'  Pass:\'' + default_info[1] + '\'  Host:\'' + 
                        default_info[2] + '\'  Database:\'' + default_info[3] + '\' Email (for url opener): \'' + default_info[4] + '\'\n')
                input_str = raw_input('\nAccept default values?  Type \'y\' and enter to accept.')
                if input_str.lower() != 'y':
                    write('\nPlease input new login values.\n')
                    default_info[0] = base64.b64encode(raw_input('Please input username:  '))
                    default_info[1] = base64.b64encode(raw_input('Please input password:  (note that this is stored binary form at ' + cfg_path + ', not encrypted:'))
                    default_info[2] = base64.b64encode(raw_input('Please input hostname: '))
                    default_info[3] = base64.b64encode(raw_input('Please input database name: '))
                    default_info[4] = base64.b64encode(raw_input('Please input email address (optional for url opener): '))
                    input_str = raw_input('Use credentials?  Type \'y\' to use.')
                else:
		    default_info = ([base64.b64encode(default_info[0]),base64.b64encode(default_info[1]),
		            base64.b64encode(default_info[2]), base64.b64encode(default_info[3]), base64.b64encode(default_info[4])])
                if input_str.lower() == 'y': 
                    loop = False
                    cfg_file = open(cfg_path, 'wb')
                    pickle.dump(default_info, cfg_file, -1)
                    cfg_file.close()
                else:
	            loop = False
	return ([base64.b64decode(default_info[0]), base64.b64decode(default_info[1]), base64.b64decode(default_info[2]), 
                base64.b64decode(default_info[3]), base64.b64decode(default_info[4])])
