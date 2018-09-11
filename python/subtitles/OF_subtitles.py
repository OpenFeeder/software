# -*- coding: utf-8 -*-
"""
Created on Tue Sep 11 15:52:14 2018

@author: jerome
"""
import platform
import os
from datetime import datetime


def of_subtitles_to_srt(ev, X, srt_file, video_begin_time=None, separator='; '):

    if video_begin_time is None:
        video_begin_time = []
        video_begin_time.append(ev[0])
        video_begin_time.append(ev[1])
        video_begin_time.append(ev[2])

    dt_video_begin_time = datetime(2000, 1, 1,
                                   video_begin_time[0],
                                   video_begin_time[1],
                                   video_begin_time[2])

    td_begin_subtitle = datetime(2000, 1, 1,
                                 int(ev[0]),
                                 int(ev[1]),
                                 int(ev[2])) - dt_video_begin_time

    section_number = 1

    subtitle = X[ev[3]-1].replace('OF_', '')

    file = open(srt_file, 'w')

    for n in range(4, len(ev), 4):

        if ev[n] == ev[n-4] and ev[n+1] == ev[n-3] and ev[n+2] == ev[n-2]:

            subtitle += separator + X[ev[n+3]-1].replace('OF_', '')

        else:

            td_end_subtitle = datetime(2000, 1, 1,
                                       int(ev[n]),
                                       int(ev[n+1]),
                                       int(ev[n+2])) - dt_video_begin_time

            begin_hours = int(td_begin_subtitle.total_seconds())//3600
            begin_minutes = (int(td_begin_subtitle.total_seconds())-begin_hours*3600)//60
            begin_seconds = int(td_begin_subtitle.total_seconds())-begin_hours*3600-begin_minutes*60

            end_hours = int(td_end_subtitle.total_seconds())//3600
            end_minutes = (int(td_end_subtitle.total_seconds())-end_hours*3600)//60
            end_seconds = int(td_end_subtitle.total_seconds())-end_hours*3600-end_minutes*60

            file.write('{}\n{:02d}:{:02d}:{:02d},000 --> {:02d}:{:02d}:{:02d},000\n{}\n\n'.format(section_number,
                       begin_hours, begin_minutes, begin_seconds,
                       end_hours, end_minutes, end_seconds, subtitle))

            td_begin_subtitle = datetime(2000, 1, 1,
                                         int(ev[n]),
                                         int(ev[n+1]),
                                         int(ev[n+2])) - dt_video_begin_time

            section_number += 1

            subtitle = X[ev[n+3]-1].replace('OF_', '')

    file.close()


def of_subtitles_to_usf(ev, X, usf_file, video_begin_time=None, separator='; '):

    if video_begin_time is None:
        video_begin_time = []
        video_begin_time.append(ev[0])
        video_begin_time.append(ev[1])
        video_begin_time.append(ev[2])

    stop_or_duration = 0

    dt_video_begin_time = datetime(2000, 1, 1,
                                   video_begin_time[0],
                                   video_begin_time[1],
                                   video_begin_time[2])

    td_begin_subtitle = datetime(2000, 1, 1,
                                 int(ev[0]),
                                 int(ev[1]),
                                 int(ev[2])) - dt_video_begin_time

    file = open(usf_file, 'w')

    file.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    file.write('<USFSubtitles version="1.0">\n')
    file.write('  <metadata>\n')
    file.write('    <title>OF subtitles</title>\n')
    file.write('    <author>\n')
    file.write('      <name>Jerome Briot</name>\n')
    file.write('      <email>jbtechlab@gmail.com</email>\n')
    file.write('    </author>\n')
    file.write('    <language code="eng">English</language>\n')
    file.write('    <date>{}-{:02d}-{:02d}</date>\n'.format(datetime.now().year,
               datetime.now().month,
               datetime.now().day))
    file.write('    <comment></comment>\n')
    file.write('  </metadata>\n  <subtitles>\n    <language code="eng">English</language>\n')

    subtitle = X[ev[3]-1].replace('OF_', '')

    for n in range(4, len(ev), 4):

        if ev[n] == ev[n-4] and ev[n+1] == ev[n-3] and ev[n+2] == ev[n-2]:

            subtitle += separator + X[ev[n+3]-1].replace('OF_', '')

        else:

            td_end_subtitle = datetime(2000, 1, 1,
                                       int(ev[n]),
                                       int(ev[n+1]),
                                       int(ev[n+2])) - dt_video_begin_time

            begin_hours = int(td_begin_subtitle.total_seconds())//3600
            begin_minutes = (int(td_begin_subtitle.total_seconds())-begin_hours*3600)//60
            begin_seconds = int(td_begin_subtitle.total_seconds())-begin_hours*3600-begin_minutes*60

            end_hours = int(td_end_subtitle.total_seconds())//3600
            end_minutes = (int(td_end_subtitle.total_seconds())-end_hours*3600)//60
            end_seconds = int(td_end_subtitle.total_seconds())-end_hours*3600-end_minutes*60

            duration_hours = int(td_end_subtitle.total_seconds()-td_begin_subtitle.total_seconds())//3600
            duration_minutes = (int(td_end_subtitle.total_seconds()-td_begin_subtitle.total_seconds())-duration_hours*3600)//60
            duration_seconds = int(td_end_subtitle.total_seconds()-td_begin_subtitle.total_seconds())-duration_hours*3600-duration_minutes*60

            if stop_or_duration:
                file.write('    <subtitle start="{:02d}:{:02d}:{:02d}.000" duration="{:02d}:{:02d}:{:02d}.000">\n      <text>{}</text>\n    </subtitle>\n'.format(
                           begin_hours, begin_minutes, begin_seconds,
                           duration_hours, duration_minutes, duration_seconds, subtitle))
            else:
                file.write('    <subtitle start="{:02d}:{:02d}:{:02d}.000" stop="{:02d}:{:02d}:{:02d}.000">\n      <text>{}</text>\n    </subtitle>\n'.format(
                           begin_hours, begin_minutes, begin_seconds,
                           end_hours, end_minutes, end_seconds, subtitle))

            td_begin_subtitle = datetime(2000, 1, 1,
                                         int(ev[n]),
                                         int(ev[n+1]),
                                         int(ev[n+2])) - dt_video_begin_time

            subtitle = X[ev[n+3]-1].replace('OF_', '')

    file.write('  <subtitles>\n')
    file.write('</USFSubtitles>')

    file.close()


def of_subtitles_to_sub(ev, X, sub_file, video_begin_time=None, separator='; '):

    if video_begin_time is None:
        video_begin_time = []
        video_begin_time.append(ev[0])
        video_begin_time.append(ev[1])
        video_begin_time.append(ev[2])

    dt_video_begin_time = datetime(2000, 1, 1,
                                   video_begin_time[0],
                                   video_begin_time[1],
                                   video_begin_time[2])

    td_begin_subtitle = datetime(2000, 1, 1,
                                 int(ev[0]),
                                 int(ev[1]),
                                 int(ev[2])) - dt_video_begin_time

    subtitle = X[ev[3]-1].replace('OF_', '')

    file = open(sub_file, 'w')

    file.write('[INFORMATION]\n')
    file.write('[TITLE] Title of film.\n')
    file.write('[AUTHOR] Author of film.\n')
    file.write('[SOURCE] Arbitrary text\n')
    file.write('[FILEPATH] Arbitrary text\n')
    file.write('[DELAY] 0\n')
    file.write('[COMMENT] Arbitrary text\n')
    file.write('[END INFORMATION]\n')
    file.write('[SUBTITLE]\n')
    file.write('[COLF]&HFFFFFF,[SIZE]12,[FONT]Times New Roman)\n')

    for n in range(4, len(ev), 4):

        if ev[n] == ev[n-4] and ev[n+1] == ev[n-3] and ev[n+2] == ev[n-2]:

            subtitle += separator + X[ev[n+3]-1].replace('OF_', '')

        else:

            td_end_subtitle = datetime(2000, 1, 1,
                                       int(ev[n]),
                                       int(ev[n+1]),
                                       int(ev[n+2])) - dt_video_begin_time

            begin_hours = int(td_begin_subtitle.total_seconds())//3600
            begin_minutes = (int(td_begin_subtitle.total_seconds())-begin_hours*3600)//60
            begin_seconds = int(td_begin_subtitle.total_seconds())-begin_hours*3600-begin_minutes*60

            end_hours = int(td_end_subtitle.total_seconds())//3600
            end_minutes = (int(td_end_subtitle.total_seconds())-end_hours*3600)//60
            end_seconds = int(td_end_subtitle.total_seconds())-end_hours*3600-end_minutes*60

            file.write('{:02d}:{:02d}:{:02d}.00,{:02d}:{:02d}:{:02d}.00\n{}\n\n'.format(
                       begin_hours, begin_minutes, begin_seconds,
                       end_hours, end_minutes, end_seconds, subtitle))

            td_begin_subtitle = datetime(2000, 1, 1,
                                         int(ev[n]),
                                         int(ev[n+1]),
                                         int(ev[n+2])) - dt_video_begin_time

            subtitle = X[ev[n+3]-1].replace('OF_', '')

    file.close()


if __name__ == '__main__':

    # Subtitle timing: 12:00:00 -> 12:00:05 -> 12:00:10 -> 12:00:15
    ev = [12, 0, 0, 1, 12, 0, 5, 2, 12, 0, 10, 3, 12, 0, 15, 4]
    X = ['Subtitle #1', 'Subtitle #2', 'Subtitle #3', 'Subtitle #4']

    separator = ','

    if platform.system() == 'Windows':
        srt_file = os.path.join(os.getenv('USERPROFILE'), 'Desktop', 'OF_subtitles_Python.srt')
    else:
        srt_file = os.path.join('~/Desktop', 'Desktop', 'OF_subtitles_Python.srt')

    of_subtitles_to_srt(ev, X, srt_file, None, separator)

    usf_file = srt_file.replace('.srt', '.usf')
    of_subtitles_to_usf(ev, X, usf_file, None, separator)

    sub_file = srt_file.replace('.srt', '.sub')
    of_subtitles_to_sub(ev, X, sub_file, None, separator)

