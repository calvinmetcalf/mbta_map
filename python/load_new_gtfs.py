# Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
# It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
# and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
# may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

#!/usr/bin/python

import sys
import mysql.connector
import zipfile
import urllib2  #! for browser
from urllib2 import urlopen
import datetime
from datetime import datetime
import hashlib
import traceback
from sql_login_info import Db_Login_Credentials
from mbta_common_utils import Common_Utils
import multiprocessing
from multiprocessing import Process
import time

def execute_insertions(__min_mysql_id__, __max_mysql_id__, __sql_phrase__, __credential_list__):
    __utils_class__ = Common_Utils()
    __write__ = sys.stdout.write
    
    __cnx__ = mysql.connector.connect(user=__credential_list__[0], password=__credential_list__[1],
                                  host=__credential_list__[2],
                                  database=__credential_list__[3],
                                  get_warnings=True,
                                  buffered=True)
        
    __cursor__ = __cnx__.cursor()
    
    __mult_record_incr__ = 2000
            
    for __first__ in range(__min_mysql_id__, __max_mysql_id__, __mult_record_incr__):
        __sql_data__ = ({
                u'min_mysql_id' : __first__,
                u'max_mysql_id' : __first__ + __mult_record_incr__
                })
                
        try:
             __cursor__.execute(__sql_phrase__,__sql_data__)
             get_sql_warnings(__cursor__, __sql_phrase__, __sql_data__)
        except:
             __utils_class__.sql_error(__sql_phrase__, __sql_data__, u'Error 995:  Problem copying temporary table to permanent (Operation failed).')
              
    __cnx__.commit()
    __cursor__.close()
    __cnx__.close()
  
#! write out data
def write_sql_output(__sql_phrase__, __sql_data_list__, __warnings_returned__, cursor,cnx):
    
    if len(__sql_data_list__) > 0:
        for __q__ in range(0, len(__sql_data_list__), 1):
            try:
                cursor.execute(__sql_phrase__, __sql_data_list__[__q__])
                __warnings_returned__ = get_sql_warnings(cursor, __sql_phrase__, __sql_data_list__[__q__])
                diag_output(__q__, __warnings_returned__)
            except:
                print __sql_phrase__
                print __sql_data_list__[__q__]
                traceback.print_exc(file=sys.stdout)
                sys.exit()
    cnx.commit()    
    write = sys.stdout.write
    write('\r                                                                                          ')
    return __warnings_returned__

#! provide diagnostics
def diag_output(__count__, __warnings_returned__):
    _write_ = sys.stdout.write
    #! diagnostic output
    if divmod(__count__, 1000)[1] == 0:
        _write_('\rProcessing:' + str(__count__) + ' ')
        if __warnings_returned__ == True: _write_('       !!')
        sys.stdout.flush()
      
    return

#! get sql warnings
def get_sql_warnings(__cursor__, __sql_phrase__, __sql_data__):
    if __cursor__.fetchwarnings():
        _write_ = sys.stdout.write
        _write_(str('\nsql error: \n'))
        _write_(str(__sql_data__) + '\n')
        _write_(str(__sql_phrase__) + '\n')
        _write_(str(__cursor__.fetchwarnings()) + '\n' + '\n')
        
        __warnings_returned__ = True
    else:
        __warnings_returned__ = False
    
    return __warnings_returned__


#! read data on line, needs list of the slice location of first character
#! and list of columns enclosed by quotations 0 for "". -1 for none
def read_data(line):
   
    last_char_locs = []

    #! special logic for first character on the line
    if line[0] in '\'\" ' :  
        first_char_locs = [1]
        quotes = [0]
    else:
        quotes = [-1]
        first_char_locs = [0]

    #! iterate through all characters in the line, looking for  
    #! commas and quotations or some combinations
    for j in range((first_char_locs[0] + 1), len(line), 1):
        if (
                (line[j] == ',' and quotes[-1] == -1) or
                (line[j-1] in '\'\"' and line[j] == ',' and quotes[-1] == 0)
                ):
         
            if quotes[-1] == -1:
                last_char_locs.append(j)
            else:
                last_char_locs.append(j-1)

         
            if line[j+1] in '\'\"':
                first_char_locs.append(j+2)
                quotes.append(0)
            else:
                first_char_locs.append(j+1)
                quotes.append(-1)
   
    #! special logic for line endings
    if line[-3] in '\'\"':
        last_char_locs.append(len(line) - 3)
    else:
        last_char_locs.append(len(line) - 2)
   
    #! at this point have a lists of: (1) first character locations, 
    #! (2) last character locations, and (3) yes/nos for whether data is
    #! enclosed in quotes
    data = []
    for j in range(0, len(first_char_locs), 1):
         
        #! read field names, account for commas or no commas
        field = line[first_char_locs[j]:last_char_locs[j]]
        if len(field) > 0:
            if field[0] == u' ':  
                field = field[1:]
            if field[-1] == u' ':  
                field = field[:-1]
      
        #! change data type for mysql compatibility
        if quotes[j-1] == -1 and field == '':
            field = None

        #! create list of data in fields
        data.append(field)
   
    #! returns list of data without commas and quotes
    return data

def tables_def():
    _tables_ = [
              [u'feed_info.txt',u'sched_feed_info'],
              [u'calendar.txt',u'sched_cal'],
              [u'stops.txt',u'sched_stops'],
              [u'trips.txt',u'sched_trips'], 
              [u'transfers.txt',u'sched_transfers'],
              [u'stop_times.txt',u'sched_stop_times'],
              [u'agency.txt',u'sched_agency'],
              [u'calendar_dates.txt',u'sched_cal_dates'],
              [u'frequencies.txt',u'sched_freq'],
              [u'routes.txt',u'sched_routes'],
              [u'shapes.txt',u'sched_shapes']
              ]

    return _tables_

class Load_GTFS_Schedules:
    
    def __init__(self):
        self.name = 'load_schedules'
        self.object = 'sched_to_temp_tables'
        self.object = 'write_temp_scheds_to_perm'
        self.object = 'write_origins_dests_table'
        
    #! this does the downloading and saving
    def sched_to_temp_tables(self, credential_list):
        utils_class = Common_Utils()
        write = sys.stdout.write
        
        utils_class.event_log(u'Checking for new schedule...')
        
        url = 'http://www.mbta.com/uploadedfiles/MBTA_GTFS.zip'
        #url = 'file:///home/doug/dev/mbta_ontime/data/MBTA_GTFS.zip'  #! uncomment for diagnostics to avoid hogging bandwidth

        sql_path = u'../sql_scripts/load_gtfs_data/'

        #! mysql connection string
        cnx = mysql.connector.connect(user=credential_list[0], password=credential_list[1],
                                  host=credential_list[2],
                                  database=credential_list[3],
                                  get_warnings=True,
                                  buffered=True)

        #! custom opener to allow feedback
        opener = urllib2.build_opener()
        opener.addheaders = [('User-Agent', 'Custom_agent/Python-urllib/2.7.3'), ('From',credential_list[4])]

        columns_all_tables = []
        cursor = cnx.cursor()
        cursor_2 = cnx.cursor()

        count_multiplier = 1000000


        #! hard coded table names and zip names
        #! input text file, output mysql table
        tables = tables_def()
        
        #! confirm that all necessary tables exist
        try:
           cursor.execute(u"SHOW TABLES;")
        except:
           utils_class.sql_error(u'SHOW TABLES',{},u'Error 001:  Failed to retrieve database table list.  (UNHANDLED)')
           sys.exit('Schedule load:  terminated.')
        
        table_check = []

        #! if there are no tables at all ...
        try:
            add_table_check = cursor.fetchone()[0]
        except:
            sys.exit('\n\nNo gtfs tables created.  Aborting\n')
            traceback.print_exc(file=sys.stdout)
        
        del_temp_tables = []
        
        #! loop through and see if the other required tables are there
        #! also check to see if temp tables were not deleted after previous update
        #! drop temp tables
        while add_table_check != None:
    
            if add_table_check != None:
                table_check.append(add_table_check)
                if add_table_check[0:6] == 'sched_' and (
                       add_table_check[-7:] in ['_temp_i','_temp_u']):
                    try:
                        sql_phrase = u'DROP TABLE ' + add_table_check + u';'
                        cursor_2.execute(sql_phrase)
                    except:
                        utils_class.sql_error(sql_phrase,{},u'Error S000: Temporary table detected on initialization, failed to drop (1st att).')
                    
            try:
                add_table_check = cursor.fetchone()[0]
            except:
                add_table_check = None

        for i in range(0, len(tables), 1):
            if tables[i][1] not in table_check:  sys.exit('\n\nTable ' + tables[i][1] + ' must be created\n\n Aborting\n')
            
        #! find the highest feed id
        sql_phrase_b = u"SELECT MAX(mysql_id) FROM mbta_data.sched_feed_info;"
        try:
            cursor.execute(sql_phrase_b)
   
            try:
                max_feed_mysqlid = int(cursor.fetchone()[0])
            except:
                max_feed_mysqlid = 0
        except:
            utils_class.sql_error(sql_phrase_b,{},u'ERROR S004:  Failed to retrieve last feed id.')
            sys.exit(u'Schedule load:  terminated.')
 
        #! get html metadata without downloading file
        if max_feed_mysqlid != 0:

            sql_phrase = "SELECT html_file_etag, html_file_content_length FROM sched_feed_info WHERE mysql_id = %(max_feed_mysqlid)s"
            sql_data = ({u'max_feed_mysqlid' : max_feed_mysqlid})
            
            try:
                cursor.execute(sql_phrase,sql_data)
                sql_catchbasin = cursor.fetchone()   #! contents [etag,content-length]
            except:
                utils_class.sql_error(sql_phrase, sql_data, u'ERROR S050:  Failed to retrieve last feed metadata.')
                
        else:
            sql_catchbasin = ['',0]
        
        html_file_etag = ''
        html_file_content_length = 0
        
        if url[0] != u'f':  #! not downloading local file
            req_head = urllib2.Request(url)
            req_head.get_method = lambda : 'HEAD'
            response = urllib2.urlopen(req_head)

            html_file_etag = response.info()['ETag']
            html_file_content_length = response.info()['Content-Length']

            #! check to see if the metadata indicates that this is a new file
            utils_class.event_log(unicode(url) + u'  html_file_etag:' + html_file_etag + 
                    u',  html_file_content_length:' + html_file_content_length) 
            
            if int(html_file_content_length) == sql_catchbasin[1] and sql_catchbasin[1] > 0:  #! only check against file length because e-tag keeps changing
                
                utils_class.event_log(u'Same metadata as last downloaded feed.  Schedule not downloaded.  Terminated.\n')
                
                #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                #!
                #!  As backup check, should check last dates on calendar
                #!  download if they are almost here
                #!
                #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                
                return False
                sys.exit('\nChecked url.  Local feed same metainformation as remote.  Ended gtfs load routine.\n')
            
            else:
                    utils_class.event_log(u'Remote metadata suggests new download.  Fetching.')
        
        #! if everything is going to be overwritten, ask for confirmation
        if max_feed_mysqlid == 0:    
            while 1:
                term_string = raw_input('No prior gfts records detected.  Create first feed?  Type ''n'' to cancel, ''y'' to continue.')
                if term_string == 'n' or term_string == 'N':
                    utils_class.event_log(u'Terminating based on user input\n')
                    sys.exit()
                else:
                    if term_string == 'y' or term_string == 'Y':
                        break

        #! dowload zip file, name it, open it as zip_f
        zip_page = opener.open(url)
        current_t = datetime.now()
        current_t_str = (unicode(current_t.year) + u'-' + unicode(current_t.month) + u'-' + unicode(current_t.day) + u'_h' +
                unicode(current_t.hour) + u'm' + unicode(current_t.minute))
        with open((u'../data/MBTA_GTFS_' + current_t_str + u'.zip'),'wb') as local_gtfs_file:
            local_gtfs_file.write(zip_page.read())

        zip_f = zipfile.ZipFile('../data/MBTA_GTFS_' + current_t_str + u'.zip','r')
        
        for p in range(0,len(tables),1):
           
            sql_phrase = utils_class.read_sql_script(u'../sql_scripts/load_gtfs_data/' + tables[p][1] + u'_temp_u.sql')
    
            try:
                cursor.execute(sql_phrase)
            except mysql.connector.errors.ProgrammingError:
                sql_phrase_x = u"DELETE FROM " + tables[p][1] + u"_temp_u;"
                try:
                    cursor.execute(sql_phrase_x)
                except:
                    utils_class.sql_error(sql_phrase_x,{},u'Error S001A:  Failed to delete leftover table.')
            except:
                utils_class.sql_error(sql_phrase, {}, u'Error S002A:  Problem creating temporary table.')
                sys.exit()
    
            sql_phrase = utils_class.read_sql_script(u'../sql_scripts/load_gtfs_data/' + tables[p][1] + u'_temp_i.sql')
            try:
                cursor.execute(sql_phrase)
            except mysql.connector.errors.ProgrammingError:
                sql_phrase_x = u"DELETE FROM " + tables[p][1] + u"_temp_i;"
                try:
                    cursor.execute(sql_phrase_x)
                except:
                    utils_class.sql_error(sql_phrase_x,{},u'Error S001B:  Failed to delete leftover table.')
            except:
                cursor.execute(sql_phrase)
                utils_class.sql_error(sql_phrase, {}, u'Error S002B:  Problem creating temporary table.')
                sys.exit()

        cnx.commit()  #! save new temp tables

        #! loop through all of the text files in the zip repository
        for i in range(0, len(tables), 1):
            sql_data_b_many = []
            sql_data_c_many = []
            count_offset_b = 0  #! writes every million, for tracking
            count_offset_c = 0

            write('\n\nFile:' + tables[i][0] + ' --> ' + tables[i][1] + u'\n')


   
            f = zip_f.open(str(tables[i][0]), 'r')
      
            #! read the first line of the text file and figure out how this is labeled and formatted
            line = f.readline()

            #! get names of columns
            #! this is used as column names
            column_names = read_data(line)
   
            count = 0
            quitflag = -1

            #! generate insert statement
            #! matches text file name against mysql table
            #! uses text file columns to match mysql column names
            #! this same statement is used for all mysql lines in file
   
            columns_all_tables.append(column_names)

            sql_phrase_b = u"INSERT INTO " + unicode(tables[i][1]) + u"_temp_i ("
   
            #! iterate through column names and add to phrase
            for j in range(0, len(column_names), 1):
                sql_phrase_b += unicode(column_names[j])
                if j != len(column_names)-1:  sql_phrase_b += u","
   
            #! difference between feed id table and other tables, column identification
            if i != 0:  
                sql_phrase_b += u',feed_id_first,feed_id_last' 
            else:
                sql_phrase_b += u',html_file_etag,html_file_content_length'
   
            #! write the sql phrase for matching against hashes
            sql_phrase_b += u",data_hash) VALUES ("
            for j in range(0, len(column_names), 1):
                sql_phrase_b += u"%(" + unicode(column_names[j]) + u")s"
                if j != len(column_names)-1:  sql_phrase_b += u", "

            #! difference between the feed id table and the others, data insertion
            if i != 0:  
                sql_phrase_b += u', %(feed_id_first)s, %(feed_id_last)s'   
            else:
                sql_phrase_b += u', %(html_file_etag)s, %(html_file_content_length)s'
   
            sql_phrase_b += u", UNHEX(%(data_hash)s))"

            #! match against data hash
            sql_phrase_a = (u"SELECT mysql_id ")
            if i != 0:  sql_phrase_a += (u",feed_id_last ")
            sql_phrase_a += (u"FROM " + unicode(tables[i][1]) + u" WHERE HEX(data_hash)=%(data_hash)s "
                    u"AND " + unicode(column_names[0]) + u"=%(" + unicode(column_names[0]) + u")s;") 
           

            sql_phrase_c = (u"INSERT INTO " + unicode(tables[i][1]) + u"_temp_u (mysql_id, feed_id_last) "
                    u"VALUES(%(matching_record)s,%(feed_id_last)s) ")
        
            sys.stdout.flush()
            warnings_returned = False

            #! iterate through all other lines in text file
            #! enter into sql_data dictionary, dumped into cursor
            while 1:
                intermed_write = False
                count +=1  #!  measures number of loops/lines
      
                line = f.readline()
                if not line:  break
                data = read_data(line)
      
                #! clear dictionary
                sql_data = {}
      
   
                #! zipper column names with data in line, into dictionary
                hash_str = u''
                for j in range(0, len(data), 1):
                    sql_data.update({column_names[j] : data[j]})
                    hash_str += unicode(data[j])
         
                #! locate any matching rows in existing tables
                #! make match with md5 hash and first column
                hasher = hashlib.md5()
                hasher.update(hash_str)
                sql_data.update({u'data_hash' : (hasher.hexdigest())})

                cursor.execute(sql_phrase_a, sql_data)
      
                try:
                    sql_catchbasin = cursor.fetchone()
                    matching_record = int(sql_catchbasin[0])
                    cursor.fetchall()
                except:
                    matching_record = None
        
                #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                #! Should add catch exception conditions:  more than one feed id
                #! more than one item match
                #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
                try:
                    if i != 0:
                        matching_rec_last_feed_id = int(sql_catchbasin[1])
                except:
                    matching_rec_last_feed_id = 0
          
                
                #! is this the same feed id as the max?  or higher?
                #! compare the feed header.  If exact, redo last feed
                #! if not exact, advance feed + 1 and run update
      
                if i == 0:
                    utils_class.event_log(u'Matching feed: ' + unicode(matching_record) + u' ' + unicode(max_feed_mysqlid))
                    if max_feed_mysqlid == 0:
                        cur_feed_id = 1
                    else:
                        if matching_record == max_feed_mysqlid:
                            sql_phrase_x = "UPDATE sched_feed_info SET html_file_etag=%(html_file_etag)s, html_file_content_length=%(html_file_content_length)s WHERE mysql_id=%(max_feed_mysqlid)s"
                            sql_data_x = ({
                                    u'html_file_etag' : html_file_etag,
                                    u'html_file_content_length' : html_file_content_length,
                                    u'max_feed_mysqlid' : max_feed_mysqlid
                                    })
                            try:
                                cursor_2.execute(sql_phrase_x, sql_data_x)
                            except:
                                utils_class.sql_error(sql_phrase_x, sql_data_x, u'Error S701:  Failed to update html metadata to matched header. (continuing)')
                                
                            cnx.commit()
                            cur_feed_id = max_feed_mysqlid
                    
                        else:
                            cur_feed_id = max_feed_mysqlid + 1
                    
                    utils_class.event_log(' --> Current Feed: ' + str(cur_feed_id))
                
      
                sql_data.update({u'matching_record' : matching_record})
      
                if matching_record == None:
                    sql_data.update({
                            u'feed_id_first' : cur_feed_id,
                            u'feed_id_last' : cur_feed_id
                            })
                    if i == 0:
                        sql_data.update({
                                u'html_file_etag' : html_file_etag,
                                u'html_file_content_length' : html_file_content_length
                                })
                        
                    #! add to aggregate list of of insertion data
                    sql_data_b_many.append(sql_data)
                    
                else:
          
                    if i != 0 and (cur_feed_id != matching_rec_last_feed_id):
                        #! add to aggregate list of strings to update
                        sql_data_c_many.append({
                                u'feed_id_last' : cur_feed_id,
                                u'matching_record' : sql_data['matching_record']
                                })
      
                diag_output(count, warnings_returned)
                if len(sql_data_b_many) > count_multiplier:  
                    warnings_returned = write_sql_output(sql_phrase_b,sql_data_b_many,warnings_returned,cursor,cnx)
                    intermed_write = True
                    count_offset_b += 1
          
                if len(sql_data_c_many) > count_multiplier:
                    warnings_returned = write_sql_output(sql_phrase_c,sql_data_c_many,warnings_returned,cursor,cnx)
                    intermed_write = True
                    count_offset_c += 1
           
                if intermed_write == True:
                    write('\rIntermediate temp table write.                                         \n')
                    sql_data_b_many = []
                    sql_data_c_many = []
                    cnx.commit()
                
      

            write(u'\r                                                                               \n')
            sys.stdout.flush()
            #! execute all insertions              
            #! data into cursor, if there are warnings, print them
            
            warnings_returned = write_sql_output(sql_phrase_b,sql_data_b_many,warnings_returned,cursor,cnx)
   
            utils_class.event_log(u'Insertions temp table complete: ' + unicode(len(sql_data_b_many) + (count_offset_b * count_multiplier)))
            write(u'\n')
            warnings_returned = write_sql_output(sql_phrase_c,sql_data_c_many,warnings_returned,cursor,cnx)
   
            utils_class.event_log(u'Updates temp table complete: ' + unicode(len(sql_data_c_many) + (count_offset_c * count_multiplier)))

            if quitflag == 0 :  break
            cnx.commit()
   
        f.close()
        zip_f.close()
        cursor.close()
        cnx.close()
        
        utils_class.event_log(u'New schedule downloaded.  Temporary files created.  Run write_temp_scheds_to_perm to save to permant.')
        
        return True

    def write_temp_scheds_to_perm( self, credential_list ):
        utils_class = Common_Utils()
        write = sys.stdout.write
        
        tables = tables_def()
        
        #! mysql connection string
        cnx = mysql.connector.connect(user=credential_list[0], password=credential_list[1],
                                  host=credential_list[2],
                                  database=credential_list[3],
                                  get_warnings=True,
                                  buffered=True)

        cursor = cnx.cursor()
        temp_types = [u'i',u'u']
        
        write('\nWriting temporary tables to permanent ...')
        for i in range(0,len(tables), 1):
          
            column_names = []
            
            sql_phrase = u"DESCRIBE " + tables[i][1]
            try:
                cursor.execute(sql_phrase)
            except:
                utils_class.sql_error(sql_phrase, {}, u'Error 2001:  Could not retrieve table column names (operation failed).')
                sys.exit()
            
            column_name = cursor.fetchone()[0]
            while column_name:            
                if column_name != u'mysql_id':
                    column_names.append(column_name)
                try:
                    column_name = cursor.fetchone()[0]
                except TypeError:
                    break
            
            sql_phrase_b = u"INSERT INTO " + unicode(tables[i][1]) + u" ("
   
            #! iterate through column names and add to phrase
            for j in range(0, len(column_names), 1):
                sql_phrase_b += unicode(column_names[j])
                if j != len(column_names)-1:  sql_phrase_b += u","
   
            #! write the sql phrase for matching against hashes
            sql_phrase_b += u") SELECT " 
            for j in range(0, len(column_names), 1):
                sql_phrase_b +=  unicode(column_names[j])
                if j != len(column_names)-1:  sql_phrase_b += u", "

            sql_phrase_b += (u" FROM " + unicode(tables[i][1]) + "_temp_i")

            sql_phrase_c = (u"UPDATE " + unicode(tables[i][1]) + u"," + unicode(tables[i][1]) + u"_temp_u SET " + 
                    unicode(tables[i][1]) + u".feed_id_last=" + unicode(tables[i][1]) + u"_temp_u.feed_id_last " + 
                    u"WHERE " + unicode(tables[i][1]) + u".mysql_id=" + unicode(tables[i][1]) + u"_temp_u.mysql_id")

            #! additional limitations for temp tables where there are lots and lots of records
            sql_phrase_b_mult = unicode(sql_phrase_b)
            sql_phrase_c_mult = unicode(sql_phrase_c)
            
            sql_phrase_b_mult += u" WHERE mysql_id>%(min_mysql_id)s AND mysql_id<=%(max_mysql_id)s;"
            sql_phrase_c_mult += u" AND " + unicode(tables[i][1]) + "_temp_u.mysql_id>%(min_mysql_id)s AND " + unicode(tables[i][1]) + "_temp_u.mysql_id<=%(max_mysql_id)s;"


            #! insert new records from temp tables
            #! two ways: all of the records, or if more than increments
            sql_phrase = (u"SELECT MIN(mysql_id), MAX(mysql_id), COUNT(mysql_id) FROM " + tables[i][1] + u"_temp_i")
            cursor.execute(sql_phrase)
            sql_catchbasin = cursor.fetchone()  #! [min_mysql_id, max_mysql_id]
            if sql_catchbasin[0] == None:  sql_catchbasin = [0,0,0]
            
            
            
            utils_class.event_log(u'Adding insertion records to ' + tables[i][1])
            
            #! using multiprocessing to write insertions to permanent tables
            max_processes = 5
            block_incr = 120000
            process_dict = {}
            
            if sql_catchbasin[1] != 0:
                for block_min in range(sql_catchbasin[0] - 1, sql_catchbasin[1] + 1, block_incr):
                    process_dict[block_min] = Process(target=execute_insertions, 
                            args=(block_min, (block_min + block_incr), sql_phrase_b_mult, credential_list))
                    process_dict[block_min].start()
                    while len(multiprocessing.active_children()) >= max_processes:
                        time.sleep(.5)
                while len(multiprocessing.active_children()) > 0:
                    time.sleep(1)
                
            write(u'\r                                               ')
            utils_class.event_log(unicode(sql_catchbasin[2]) + u' insertions:  complete.')
            write(u'                                          ')
            #! update records from temp tables
            #! two ways: all of the records, or if more than increments
            sql_phrase = (u"SELECT MIN(mysql_id), MAX(mysql_id), COUNT(mysql_id) FROM " + tables[i][1] + u"_temp_u")
            cursor.execute(sql_phrase)
            sql_catchbasin = cursor.fetchone()  #! [min_mysql_id, max_mysql_id]
            if sql_catchbasin[0] == None:  sql_catchbasin = [0,0,0]
            mult_record_incr = 2000
            utils_class.event_log(u'Updating unchanged records to ' + tables[i][1])
            
            if i != 0 and sql_catchbasin[1] == 0 :  #! do not run update if this is feed_info table or if there are no records, because it doesn't need updating
                
                #! use multiprocessing for writing to updates
                process_dict = {}
                
                for block_min in range(sql_catchbasin[0] - 1, sql_catchbasin[1] + 1, block_incr):
                    process_dict[block_min] = Process(target=execute_insertions, 
                            args=(block_min, (block_min + block_incr), sql_phrase_c_mult, credential_list))
                    print block_min, (block_min + block_incr)
                    process_dict[block_min].start()
                    while len(multiprocessing.active_children()) >= max_processes:
                        time.sleep(.5)
                while len(multiprocessing.active_children()) > 0:
                    time.sleep(1)
              
            write(u'\r                                               ')
            utils_class.event_log(unicode(sql_catchbasin[2]) + u' insertions:  complete.')
            write(u'                     ')
            utils_class.event_log(u'Done with ' + tables[i][1])
            write(u'\n')

        for p in range(0, len(tables), 1):
            sql_phrase = u"DROP TABLE " + tables[p][1] + u"_temp_u"
    
            try:
                cursor.execute(sql_phrase)
            except:
                utils_class.sql_error(sql_phrase, {}, u'Error 998:  Problem deleting temporary table.')
    
            sql_phrase = u"DROP TABLE " + tables[p][1] + u"_temp_i"

            try:
                cursor.execute(sql_phrase)
            except:
                utils_class.sql_error(sql_phrase, {}, u'Error 999:  Problem deleting temporary table.')

        cnx.commit()
        cursor.close()
        cnx.close()
        utils_class.event_log(u'Temporary files for new schedule written to permanent tables.')
        
        return True
        
    def write_origins_dests_table( self, credential_list ):
        utils_class = Common_Utils()
        write = sys.stdout.write

        #! mysql connection string
        cnx = mysql.connector.connect(user=credential_list[0], password=credential_list[1],
                                  host=credential_list[2],
                                  database=credential_list[3],
                                  get_warnings=True,
                                  buffered=True)

        cursor = cnx.cursor()
        write = sys.stdout.write
        utils_class.event_log(u'Querying and writing table of trips, origins, and destinations.')
        
        sql_phrase = u"DELETE FROM trips_origins_dests"
        
        try:
            cursor.execute(sql_phrase)
        except:
            utils_class.sql_error(sql_phrase,{},u'Error 5001:  Failed to delete records from trips_origins.')
            sys.exit('Terminating.')

        sql_phrase = u"SELECT MAX(mysql_id) FROM mbta_data.sched_feed_info;"
        cursor.execute(sql_phrase)
        cur_feed_id = cursor.fetchone()[0]

        sql_phrase = u"SELECT MIN(mysql_id), MAX(mysql_id), COUNT(mysql_id) FROM sched_trips;"
        cursor.execute(sql_phrase)
        first_last_pair = cursor.fetchone()
        cursor.fetchall()

        #! populate origins and destinations table
        #! in bite-sized pieces for the db
        sql_phrase = utils_class.read_sql_script('../sql_scripts/insert_origins_dests_from_python.sql')
        
        line_increment = 1000
        
        for p in range(first_last_pair[0] - 1, first_last_pair[1] + 1, line_increment):
            write(u'\rQuerying:  ' + unicode(first_last_pair[1] - p) + u' lines left.     ')
            sys.stdout.flush()
            
            sql_data = ({
                    u'cur_feed_id' : cur_feed_id,
                    u'first_mysql_id' : p,
                    u'last_mysql_id' : p + line_increment
                    })

            cursor.execute(sql_phrase,sql_data)
        
        write(u'\r')
        utils_class.event_log(unicode(first_last_pair[2]) + u' trips:  origins and destinations written to table.')
        write(u'                                              ')

        cnx.commit()
        cursor.close()
        cnx.close()
        utils_class.event_log(u'NEW SCHEDULE LOADED.  READY.\n')

