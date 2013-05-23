# Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
# It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
# and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
# may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

#!/usr/bin/python

import sys
import datetime
from datetime import datetime
import traceback

class Common_Utils:
    
    def __init__(self):
        self.name = u'common_utils'
        self.object = u'sql_error'
        self.object = u'read_sql_script'
        self.object = u'event_log'
        
    def sql_error( self, _sql_phrase_, _sql_data_, _err_message_):
        utils = Common_Utils()
        _log_path_ = u'../data/sql_errors.log'
        _log_ = open(_log_path_,'a')
        _write_ = sys.stdout.write
        _write_(u'\n' + _err_message_ + u' See log: ' + _log_path_ + u'\n')
        _log_.write(unicode(datetime.now()) + u'\n')
        _log_.write(unicode(traceback.print_exc(file=sys.stdout)) + u'\n')
        _log_.write(unicode(_sql_phrase_) + u'\n')
        _log_.write(unicode(_sql_data_) + u'\n')
        _log_.close()
    
        return True
    
    #! read named sql script, returns string
    def read_sql_script(self, _path_):
        _f_ = open(_path_, 'r')
        _output_ = u''
        _line_ = _f_.readline()
        while _line_: 
            _output_ = _output_ + u' ' + unicode(_line_)
            _line_ = _f_.readline()
        _f_.close()
        return _output_
      
    def event_log(self , __entry__ ):
        __path__ = u'../data/ontime_events.log'
        __screen__ = sys.stdout.write
        with open(__path__,'a') as __f__:
            __f__.write(u'\n' + unicode(datetime.now()) + u'  ' + unicode(__entry__))
        __screen__(u'\n' + unicode(__entry__))
        sys.stdout.flush()
        
        return True