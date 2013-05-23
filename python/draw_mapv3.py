# Copyright 2013 by Douglas R. Tillberg <doug@transitboston.com>.  This file is part of the mbta_map project. 
# It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution 
# and at https://github.com/doug0/mbta_map/blob/master/LICENSE. No part of the mbta_map project, including this file, 
# may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.

#!/usr/bin/python

from __future__ import division
import sys
import mysql.connector
import datetime
from datetime import datetime
import traceback
from sql_login_info import Db_Login_Credentials
from mbta_common_utils import Common_Utils
import time
import os

import math

from Tkinter import *
import Tkinter as tk
import tkFont

def scale_coef(__x__):  # x input should be in the range 0 to 1 (part of graph), output will be in same range
    
    # changes the scale of the map from the center
    # giving more distance for short periods of time
    # and less distance from longer periods of times
    
    # these shrink the immediate middle
    # necessary because too big on a logarithmic function

        
    # function for overall time scale
    
    __output__ = (((math.log10((( ( __x__ + 0.045) * .75 )* 0.4 )) /2) +1) -.11) / 0.62

    if __output__ < 0:  __output__ = 0
        
    return __output__


# foundation for tkinter canvas

class Application(tk.Frame):

    def __init__(self, master=None):

        tk.Frame.__init__(self, master, class_ = 'MBTA Map Canvas')
        self.grid()
        
                
        self.createWidgets()
        

    def createWidgets(self):
        
       utils_cl = Common_Utils()
       sql_path = '../sql_scripts/'

       cnx = mysql.connector.connect(user=credential_list[0], password=credential_list[1],
                                  host=credential_list[2],
                                  database=credential_list[3],
                                  get_warnings=True,
                                  buffered=True)
        
       cursor = cnx.cursor()
       cursor_high = cnx.cursor()
       
       # returns list [ [0] readable list of 'stop_mysqlid : trunc stop_name', [1] integer stop_mysqlid ]
       # this list is the stops that can serve as a map center
       
       sql_phrase = utils_cl.read_sql_script(sql_path + 'select_current_map_starts.sql')
       
       cursor_high.execute(sql_phrase)
        
       ln = cursor_high.fetchone()
       temp_log_path = u'../data/temp_log_drawmaps.log'
       
       write = sys.stdout.write

       # loops through all of the 'starts' in the 'best_times' table
       while ln:
        
        
        starting_loc = ln[1]
        try:
            starting_loc = int(starting_loc)
            
            # want start to be persistent, separate persistent variable
            starting_saved = starting_loc
        except:
            print ln[0]
            sys.exit('Starting location wasn''t an integer - exiting')

        # x_dim and y_dim are size of map in pixels, or are supposed to be
        
        x_dim = 1024
        y_dim = 1024
        
        # x_ctr and y_ctr are center points on map, or are supposed to be
        
        x_ctr = int(round(( x_dim / 2 ) + (x_dim * .175)))
        y_ctr = int(round(( y_dim / 2 ) + (y_dim * .175)))
        
        # quit button, if you need it
        
        self.quitButton = tk.Button(self, text='Quit', command=self.quit)
        self.quitButton.grid()
        can = tk.Canvas(self, height=str(y_dim) + 'p', width=str(x_dim) + 'p', bg='#fff')

        # returns [0] maximim travel time for all trips from the starting_loc
        # for purposes of getting the scale right
        
        sql_phrase = "SELECT MAX(total_time) FROM mbta_data.mbta_map_best_times WHERE start_mysqlid = %(starting_loc)s GROUP BY start_mysqlid"
        
        cursor.execute(sql_phrase, {u'starting_loc' : starting_saved})
        max_time = cursor.fetchone()[0]
        
        # defensive programming - make sure the cursor is reset
        cursor.fetchall()

        # this is the central query
        # returns the list of best times with their attributes
        # the query itself determines the total travel time and compass direction
        # that work all is done in sql
        
        sql_phrase = utils_cl.read_sql_script(sql_path + 'populate_map_points_from_start.sql')
        
        # returns list with the following index locations:
        # [0] dest_mysqlid, [1] total_time (seconds), [2] trip_count, [3] transp_mode, [4] route_mysqlid,
        # [5] route_name, [6] dest_name, [7] route_color, [8]compass, [9]trip_leg, 
        # [10] start_loc, [11] prev_stop_mysqlid,  [12]immed_prev_stop
        
        cursor.execute(sql_phrase, {u'starting_loc' : starting_loc})  
                                    
        line = cursor.fetchone()
        
        # overall structure of script:
        # makes calculatons in section below and stores them in a dictionary
        # does this for two reasons (1) want entirely to draw the lines first, then the station points on top
        # (2) line drawing requires reference to a dictionary of the locations of the previous stops
        # so need both complete dictionaries before drawing lines
        
        # initial values
        point_dict = {}
        prev_stops = {}
        max_time_route = {}
        rail_dest_list = []
        
        route_mysqlid = -1

        dest_name = ''
        
        # reads through query of stops, total times
        while line:
            
            # belt-and-suspenders: stop if no more lines of query
            if line == [] or line == None or not line:
                break
            
            # use named local variables in place of index locations
            # to make code manipularions easier to read
            
            dest_mysqlid = line[0]    
            leng = line[1]
            total_min = (line[1]) /60  # converts output time in seconds to minutes
            trip_count = line[2]
            transp_mode = line[3]
            route_mysqlid = line[4]
            route_name = line[5]
            dest_name = line[6]
            color = line[7]
            comp = line[8]
            trip_leg = line[9]
            prev_stop_mysqlid = line[11]
            immed_prev_stop = line[12]
            
            # converts count into ratio, with 2512 being the most trips for any one origin/dest pair
            # probably would be more correct to run query with MAX(count)
            
            if trip_count != None:
                trip_ratio = line[2] / 2512
                
                # gave multipliers for heavy rail service
                # otherwise bus dots are overwhelming/dominant
                
                if transp_mode == 1:  trip_ratio = trip_ratio * 1.7
                if transp_mode == 2:  trip_ratio = trip_ratio * 40
            
            else:  # avoids potential errors nonetype and div by 0 errors
                trip_ratio = .01
            
            # convert total time in seconds into distance from origin on map
            
            if leng != 0:
                leng = (x_ctr) * scale_coef( ( leng / max_time ) )

            # convert compass direction into radians
            if comp == None:
                comp = 0
            
            comp = (comp * math.pi) / 180  #convert to radians
            
            # caluclate points on map for stop
            x_point = ( math.sin(comp) * leng ) + x_ctr
            y_point = -1 * ( math.cos(comp) * leng ) + y_ctr
            
            # use white color for stops reached by walking
            if color != None:
                color = '#' + str(color)
            else:
                color = '#fff'
                
            if color.upper() == '#FFFF7C':
                color = '#E7D450'
                        
            # update dictionary of *previous* stops
            # coordinates and colors of previous stops may be used in some situations
            # where it is desired to draw the route that *departs* from the station
            # rather than the one that arrives
            if prev_stop_mysqlid not in prev_stops:
                    
                prev_stops.update({prev_stop_mysqlid : dest_mysqlid})
                  
            # if stop already in list, only update if the new route is bigger/better than old route
            # or is not walking or bus
            else:
                if ( (point_dict[prev_stops[prev_stop_mysqlid]]['trip_ratio'] < trip_ratio and
                        (point_dict[prev_stops[prev_stop_mysqlid]]['transp_mode'] in [None, 3] or 
                        transp_mode not in [None, 3])) or
                        (point_dict[prev_stops[prev_stop_mysqlid]]['transp_mode'] in [None, 3] and
                             transp_mode not in [None, 3])
                        ):
                    prev_stops.update({prev_stop_mysqlid : dest_mysqlid})

            if transp_mode != None:
                        
                if route_mysqlid not in max_time_route:
                    max_time_route.update({route_mysqlid : {'min' : leng, 'max' : leng}})
                else:
                    if leng > max_time_route[route_mysqlid]['max']:
                        max_time_route[route_mysqlid].update({'max' : leng})
                    if leng < max_time_route[route_mysqlid]['min']:
                        max_time_route[route_mysqlid].update({'min' : leng})
                
                if transp_mode != 3:
                    rail_dest_list.append(dest_mysqlid)
            
            # dictionary of all destinations and point/other info
            
            point_dict.update( { dest_mysqlid : {
                    'x_point' : x_point,
                    'y_point' : y_point,
                    'total_min' : total_min,
                    'trip_count' : trip_count,
                    'route_mysqlid' : route_mysqlid,
                    'route_name' : route_name,
                    'immed_prev_stop' : immed_prev_stop,
                    'trip_ratio' : trip_ratio,
                    'color' : color,
                    'transp_mode' : transp_mode,
                    'prev_stop_mysqlid' : prev_stop_mysqlid,
                    'comp' : comp,
                    'leng' : leng,
                    'dest_name' : dest_name
                    } })
            
            
            line = cursor.fetchone()
        
        # draw background square; covers entire canvas
        
        can.create_rectangle(0,0,x_ctr * 2.5, y_ctr * 2.5, fill='#fff', outline='#fff')
        

        # get name of origin stop
                
        sql_phrase = "SELECT stop_name FROM mbta_data.sched_stops WHERE mysql_id = %(starting_loc)s"
        cursor.execute(sql_phrase, {u'starting_loc' : starting_saved})
        
        start_name = cursor.fetchone()[0]
        cursor.fetchall()
        
        txt = start_name
        
        trunc_loc = txt.find(u' - ')
        if trunc_loc != -1:
            txt = txt[:trunc_loc]
               
        trunc_loc = txt.find(u'Station')
        if trunc_loc != -1 and u'south station' not in txt.lower() and u'north station' not in txt.lower():
            txt = txt[:trunc_loc]
        
        can.create_text(x_ctr, y_ctr - 16, text = txt, font = ('UnBom', -48), fill = '#A3A3A3', anchor = 's' )
                
        
        # add legends
        
        fl = tk.PhotoImage(file='../legend.ppm')
        
        can.create_image((x_ctr * 2) - 18, (y_ctr * 2) - 20, anchor=tk.SE, image=fl, state=tk.NORMAL)

        fl_2 = tk.PhotoImage(file='../legend_2.ppm')        

        can.create_image( 36, (y_ctr * 2) - 56, anchor=tk.SW, image=fl_2, state=tk.NORMAL)
        
        # draw the reference circles
        circle_time_mins = [15, 30, 60]
        for i in range(0, len(circle_time_mins), 1):
            
            leng = (x_ctr) * scale_coef( ( ( circle_time_mins[i] * 60 ) / max_time ) )
          
            can.create_oval(x_ctr - leng , y_ctr - leng, x_ctr + leng, y_ctr + leng, fill = '', outline = '#A3A3A3', width = 5)
            
            can.create_text(x_ctr, y_ctr - leng, text = str(circle_time_mins[i]) + 'min.', anchor = 's', font = ('UnBom', -24), fill = '#A3A3A3')
            can.create_text(x_ctr, y_ctr + leng + 2, text = str(circle_time_mins[i]) + 'min.', anchor = 'n', font = ('UnBom', -24), fill = '#A3A3A3')
        
        # this loop is run after dictionaries are completely full
        # draws the maps using data stored earlier        
        
        # draw all of the lines first
        # first so that they do not interfere with dots
        
        for i in range(1, len(point_dict.keys()), 1):
            
            immed_prev_stop = None
            
            if (point_dict[point_dict.keys()[i]]['route_mysqlid'] not in [0, None] and                
                    point_dict[point_dict.keys()[i]]['immed_prev_stop'] != None and
                    point_dict[point_dict.keys()[i]]['immed_prev_stop'] in point_dict and
                    (point_dict[point_dict.keys()[i]]['transp_mode'] == 
                    point_dict[point_dict[point_dict.keys()[i]]['immed_prev_stop']]['transp_mode'])):
              
                immed_prev_stop = point_dict[point_dict.keys()[i]]['immed_prev_stop']
                
            
            elif (point_dict[point_dict.keys()[i]]['route_mysqlid'] not in [0, None]
                  and point_dict[point_dict.keys()[i]]['immed_prev_stop'] != None):
                
                sql_phrase = utils_cl.read_sql_script(sql_path + 'select_traceback_route.sql')
                
                immed_prev_stop = point_dict[point_dict.keys()[i]]['immed_prev_stop']
                
                transp_mode = point_dict[point_dict.keys()[i]]['transp_mode']
                transp_mode_2 = None
                
                sql_data = ({
                    'origin_mysqlid' : point_dict[point_dict.keys()[i]]['prev_stop_mysqlid'],
                    'immed_prev_mysqlid' : immed_prev_stop,
                    'start_mysqlid' : starting_saved
                    })
                
                count = 0
                
                if (not (immed_prev_stop in rail_dest_list and transp_mode == transp_mode_2 ) and
                      not (immed_prev_stop == point_dict[point_dict.keys()[i]]['prev_stop_mysqlid']) and not (count >= 100)):
                    
                    trip_mode = [-1, -2, -3]
                    
                    count_2 = 0
                    while (trip_mode[0] != trip_mode[1] and
                            point_dict[point_dict.keys()[i]]['prev_stop_mysqlid'] != trip_mode[2] and 
                             point_dict[point_dict.keys()[i]]['prev_stop_mysqlid'] != immed_prev_stop
                            and count_2 <= 30):
                        
                        cursor.execute(sql_phrase, sql_data)
                        sql_catchbasin = cursor.fetchone() #one step earlier immed_prev_stop
                                                           #[0]a.immed_prev_stop, [1]a.dest_route_type, 
                                                           #[2]b.immed_prev_route_type, [3]b.dest_mysqlid, [4]b.total_time, 
                                                           #[5]a.origin_mysqlid
                        
                        cursor.fetchall() # defensive programming
                    
                        if sql_catchbasin != None:
                            if sql_catchbasin[0] != None:
                                immed_prev_stop = sql_catchbasin[0]
                            else:
                                immed_prev_stop = point_dict[point_dict.keys()[i]]['prev_stop_mysqlid']
                            trip_mode = [sql_catchbasin[1], sql_catchbasin[2], sql_catchbasin[3]]
                        else:
                            immed_prev_stop = None
                            
                        sql_data.update({'immed_prev_mysqlid' : immed_prev_stop})
                        count_2 += 1
                    if sql_catchbasin != None:
                        if immed_prev_stop in point_dict:
                            if sql_catchbasin[0] != None:
                                transp_mode_2 = point_dict[immed_prev_stop]['transp_mode']
                            else:
                                transp_mode_2 = transp_mode
                        else:
                            immed_prev_stop = None
                        
                    count += 1
                
                # only trace to first stop on route
                # if the traced-to stop is same type of stop, update dictionary
                
                if immed_prev_stop != None and immed_prev_stop in point_dict:
                        
                    if immed_prev_stop not in prev_stops:
                        
                        prev_stops.update({immed_prev_stop : point_dict.keys()[i]})
                    elif (point_dict[prev_stops[immed_prev_stop]]['transp_mode'] in [None, 3] and 
                            point_dict[point_dict.keys()[i]]['transp_mode'] not in [None, 3]):
                        prev_stops.update({immed_prev_stop : point_dict.keys()[i]})
                            
                    point_dict[point_dict.keys()[i]]['immed_prev_stop'] = immed_prev_stop
                        
            elif point_dict[point_dict.keys()[i]]['route_mysqlid'] not in [0, None]:
                
                immed_prev_stop = point_dict[point_dict.keys()[i]]['prev_stop_mysqlid']
                
            else:  immed_prev_stop = None
            
            if immed_prev_stop != None and immed_prev_stop in point_dict:
                
                higher_comp = max(point_dict[point_dict.keys()[i]]['comp'], point_dict[immed_prev_stop]['comp'])
                
                x_point = round(point_dict[immed_prev_stop]['x_point'],0) 
                y_point = round(point_dict[immed_prev_stop]['y_point'],0)
                
                if math.pow(abs(x_point - x_ctr),3) + math.pow(abs(y_point - y_ctr),3) >= 3:
                    
                    prev_comp = point_dict[immed_prev_stop]['comp']
                    cur_comp = point_dict[point_dict.keys()[i]]['comp']
                
                    if prev_comp < cur_comp:
                        compass_delta = ( cur_comp - prev_comp )
                    elif prev_comp > cur_comp:
                        compass_delta = ( (2 * math.pi) - prev_comp + cur_comp )
                    else:
                        compass_delta = 0
                
                    if compass_delta > math.pi:
                        compass_delta = ( (-2 * math.pi) + compass_delta )
                
                    leng_delta = point_dict[point_dict.keys()[i]]['leng'] - point_dict[immed_prev_stop]['leng']
                
                    comp = point_dict[immed_prev_stop]['comp']
                    leng = point_dict[immed_prev_stop]['leng']
                
                
                    num_segments = int(abs(math.ceil(compass_delta / .0628)))
                
                    line_width = str(5 * (point_dict[point_dict.keys()[i]]['trip_ratio']) + 1) + 'p'
                
                    if num_segments != 0:
                        leng_seg = leng_delta / num_segments
                        comp_seg = compass_delta / num_segments
                
                    
                        for k in range(1, num_segments, 1): 
                
                            x_last = x_point
                            y_last = y_point
                    
                            leng = leng + leng_seg
                            comp = comp + comp_seg
                    
                            x_point = ( math.sin(comp) * leng ) + x_ctr
                            y_point = -1 * ( math.cos(comp) * leng ) + y_ctr
                
                            can.create_line(x_last, y_last, x_point, y_point, 
                                    fill = point_dict[point_dict.keys()[i]]['color'], width = line_width)
                    
                can.create_line(x_point, y_point, point_dict[point_dict.keys()[i]]['x_point'], 
                        point_dict[point_dict.keys()[i]]['y_point'], 
                        fill = point_dict[point_dict.keys()[i]]['color'], width = line_width)
        
        # draw all of the stop points
        # draws on top of the lines
        
        for i in range(0, len(point_dict.keys()), 1):
          for z in range(0, 2, 1):
            color = '#fff'
              
            if z == 0 and point_dict[point_dict.keys()[i]]['transp_mode'] not in [None]:
                color = point_dict[point_dict.keys()[i]]['color']
                trip_ratio = point_dict[point_dict.keys()[i]]['trip_ratio']
                transp_mode = point_dict[point_dict.keys()[i]]['transp_mode']
                route_name = point_dict[point_dict.keys()[i]]['route_name']
                route_mysqlid = point_dict[point_dict.keys()[i]]['route_mysqlid']
                leng = point_dict[point_dict.keys()[i]]['leng']
                
            if z == 1 and point_dict.keys()[i] in prev_stops:
                if (point_dict[point_dict.keys()[i]]['transp_mode'] in [None, 3] and
                        point_dict[prev_stops[point_dict.keys()[i]]]['transp_mode'] not in [None, 3]):
                    color = point_dict[prev_stops[point_dict.keys()[i]]]['color']
                    trip_ratio = point_dict[prev_stops[point_dict.keys()[i]]]['trip_ratio']
                    transp_mode = point_dict[prev_stops[point_dict.keys()[i]]]['transp_mode']
                    route_name = point_dict[prev_stops[point_dict.keys()[i]]]['route_name']
                    route_mysqlid = point_dict[prev_stops[point_dict.keys()[i]]]['route_mysqlid']
                    leng = point_dict[prev_stops[point_dict.keys()[i]]]['leng']
            
            if color != '#fff':
                    
                x1 = point_dict[point_dict.keys()[i]]['x_point'] - 18 * trip_ratio
                x2 = point_dict[point_dict.keys()[i]]['x_point'] + 18 * trip_ratio
                y1 = point_dict[point_dict.keys()[i]]['y_point'] - 18 * trip_ratio
                y2 = point_dict[point_dict.keys()[i]]['y_point'] + 18 * trip_ratio
            
                # draw stop labels, changing the anchor location based on the map sector
            
                if 1==1:
                
                    if point_dict[point_dict.keys()[i]]['y_point'] >= y_ctr:
                        anchor_loc = 'n'
                        y_anchor = y2
                        ln_loc = [7,0]
                        
                    else:
                        anchor_loc = 's'
                        y_anchor = y1
                        ln_loc = [0,-7]
                        
                    if point_dict[point_dict.keys()[i]]['x_point'] >= x_ctr :
                        anchor_loc += 'w'
                    else:
                        anchor_loc += 'e'
                    
                    txt = point_dict[point_dict.keys()[i]]['dest_name']
                
                    # truncates annoying little extras on stop names
                    
                    trunc_loc = txt.find(u' - ')
                    if trunc_loc != -1:
                        txt = txt[:trunc_loc]
                
                    trunc_loc = txt.find(u'Station')
                    if trunc_loc != -1:
                        txt = txt[:trunc_loc]
                
                    # station name and trip time
                    txt = txt + ' (' + str(int(round(point_dict[point_dict.keys()[i]]['total_min'],0))) + '\')'
                    
                    if color.upper() == '#FFFF7C':
                        color_out = '#FCF344'
                    else:
                        color_out = color
                
                    if transp_mode != 3:
                        
                        can.create_text( point_dict[point_dict.keys()[i]]['x_point'], y_anchor, 
                                    text = txt, 
                                    font = ('UnBom', int(round((trip_ratio)) * -10) - 9 ), 
                                    fill = color, anchor = anchor_loc )
                
                    elif route_mysqlid in max_time_route:
                        
                        if leng >= max_time_route[route_mysqlid]['max'] or leng <= max_time_route[route_mysqlid]['min']:
                            font_obj = tkFont.Font(family='UnBom', size=-10)
                            
                            slice_loc = route_name.find(u' ')
                            can.create_text( point_dict[point_dict.keys()[i]]['x_point'], y_anchor + ln_loc[0], 
                                        text = route_name[:slice_loc], 
                                        font = font_obj, 
                                        fill = color_out, anchor = anchor_loc )
                
                            can.create_text( point_dict[point_dict.keys()[i]]['x_point'], y_anchor + ln_loc[1], 
                                        text = route_name[(slice_loc + 1):], 
                                        font = font_obj, 
                                        fill = color_out, anchor = anchor_loc )
                
                if color.upper() == '#FFFF7C':
                    color_out = '#FCF344'
                    color = '#FCF344'
                else:
                    color_out = color
            
                can.create_oval( x1 , y1, x2, y2, fill = color, 
                                outline = color_out )
        
        # center/start circle
        
        can.create_oval(x_ctr -12 , y_ctr - 12, x_ctr + 12, y_ctr + 12, fill='#808080')
        
        can.create_text(24, 48, text = 'Travel times from:', anchor = 'nw', font = ('Segui UI Bold', -24, 'bold'), fill = '#A3A3A3')
        can.create_text(32, 74, text = str(start_name), anchor = 'nw', font = ('Segui UI Bold', int(round(-0.07 * x_dim)), 'bold'), fill = '#A3A3A3')
        can.create_text(24, 130, text = 'Time from origin in minutes.', anchor = 'nw', font = ('Segui UI Bold', -24, 'bold'), fill = '#A3A3A3')
        
        
        can.grid()    
        can.update()
        file_name = str(start_name).lower()
        
        spc_chars = ' \\/()\'\":;&|'
        for qq in range(0, len(spc_chars), 1):
            file_name = file_name.replace(spc_chars[qq], '_')
            
        file_name += "_travel_times"
        ps_path = "../data/ps/"
        png_path = "../data/png/"
        
        can.postscript(file=ps_path + str(file_name) + ".ps", height= str(y_dim) + 'p', width = str(x_dim) + 'p')
        
        cmd = 'convert -density 220 ' + ps_path + file_name + '.ps ' + png_path + file_name + '.png'
        os.system(cmd)
        
        with open(temp_log_path,'a') as __f__:
            __f__.write(u'\n' + unicode(file_name) + u'.png')
        
        can = None
        ln = cursor_high.fetchone()
        
       cursor.close()
       cursor_high.close()
       cnx.close()
        
       
        
credentials_class = Db_Login_Credentials()
credential_list = credentials_class.get_credentials() #!db login [user,pass,hostname,db_name]

app = Application()

app.master.title('MBTA transit times')
app.mainloop()