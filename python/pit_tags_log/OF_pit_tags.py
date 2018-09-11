# -*- coding: utf-8 -*-
"""
Created on Tue Sep 11 18:26:51 2018

@author: jerome
"""

from tkinter import Tk, filedialog
from datetime import datetime
import sys
import os
import platform

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

from subtitles import OF_subtitles


def of_pit_tags_to_subtitles(csv_file, output_file, video_begin_time=None, separator='; '):

    log = of_read_pit_tags_log(csv_file)

    ev = []
    n = 0
    for d in log['date']:
        ev.append(d.hour)
        ev.append(d.minute)
        ev.append(d.second)
        ev.append(n)
        n += 1

    if output_file.endswith('.srt'):
        OF_subtitles.of_subtitles_to_srt(ev, log['pittags'], output_file, video_begin_time, separator)
    elif output_file.endswith('.sub'):
        OF_subtitles.of_subtitles_to_sub(ev, log['pittags'], output_file, video_begin_time, separator)
    elif output_file.endswith('.usf'):
        OF_subtitles.of_subtitles_to_usf(ev, log['pittags'], output_file, video_begin_time, separator)


def of_read_pit_tags_log(csv_file):

    file = open(csv_file, 'r')
    X = file.read().splitlines()
    file.close()

    log = dict((i, []) for i in ['date', 'site', 'device', 'scenario',
               'pittags', 'is_denied', 'is_reward_taken', 'led_red',
               'led_green', 'led_blue', 'door_status', 'landing_time'])

    for x in X:
        tmp = x.split(',')

        d = datetime(int(tmp[0][0:2]), int(tmp[0][3:5]), int(tmp[0][6:8]),
                     int(tmp[1][0:2]), int(tmp[1][3:5]), int(tmp[1][6:8]))

        log['date'].append(d)

        log['site'].append(tmp[2])
        log['device'].append(tmp[3])
        log['scenario'].append(tmp[4])
        log['pittags'].append(tmp[5])
        log['is_denied'].append(tmp[6])
        log['is_reward_taken'].append(tmp[7])
        log['led_red'].append(tmp[8])
        log['led_green'].append(tmp[9])
        log['led_blue'].append(tmp[10])
        log['door_status'].append(tmp[11])
        log['landing_time'].append(tmp[12])

    return log


if __name__ == '__main__':

    debug = True

    if debug:

        csv_file = r'C:\Users\jerome\Dropbox\wild_cog_2017-18\data\H1\3_gonogo_one\P7\OF_38\19_03_18\20180309.CSV'

    else:
        root = Tk()
        root.withdraw()

        csv_file = filedialog.askopenfilename(initialdir="/",
                                              title="Select file",
                                              filetypes=[("CSV files", "*.CSV")])

        if csv_file == '':
            sys.exit()

        root.destroy()

    log = of_read_pit_tags_log(csv_file)

    if platform.system() == 'Windows':
        srt_file = os.path.join(os.getenv('USERPROFILE'), 'Desktop', 'OF_pit_tag_subtitles_Python.srt')
    else:
        srt_file = os.path.join('~/Desktop', 'Desktop', 'OF_subtitles_Python.srt')

    usf_file = srt_file.replace('.srt', '.usf')
    sub_file = srt_file.replace('.srt', '.sub')

    separator = ','

    of_pit_tags_to_subtitles(csv_file, srt_file, None, separator)
    of_pit_tags_to_subtitles(csv_file, usf_file, None, separator)
    of_pit_tags_to_subtitles(csv_file, sub_file, None, separator)
