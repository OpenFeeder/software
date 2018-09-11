# -*- coding: utf-8 -*-
"""
Created on Mon Sep  3 15:06:04 2018

@author: jerome
"""

from tkinter import Tk, filedialog
import sys
import platform
import os

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

from subtitles import OF_subtitles


def of_events_to_txt(bin_file, events_file, text_file, separator=';'):

    ev, X = of_events_raw_read(bin_file, events_file)

    file = open(text_file, 'w')

    idx = 0
    for n in range(0, len(ev)//4):
        file.write('{:02d}:{:02d}:{:02d}{}{}\n'.format(ev[idx],
                                                       ev[idx+1],
                                                       ev[idx+2],
                                                       separator,
                                                       X[ev[idx+3]-1]))
        idx += 4

    file.close()


def of_events_readable_read(bin_file, subtitles_file):

    file = open(bin_file, 'rb')
    ev = file.read()
    file.close()

    file = open(subtitles_file, 'r')
    lines = file.read().splitlines()
    file.close()

    X = []
    for line in lines:
        tmp = line.split(',')
        X.append(tmp[1].lstrip())

    return ev, X


def of_events_raw_read(bin_file, events_file):

    file = open(bin_file, 'rb')
    ev = file.read()
    file.close()

    file = open(events_file, 'r')
    X = file.read().splitlines()
    file.close()

    return ev, X


def of_events_to_subtitles(bin_file, subtitles_file, output_file, video_begin_time=None, separator='; '):

    [ev, X] = of_events_readable_read(bin_file, subtitles_file)

    if output_file.endswith('.srt'):
        OF_subtitles.of_subtitles_to_srt(ev, X, output_file, video_begin_time, separator)
    elif output_file.endswith('.sub'):
        OF_subtitles.of_subtitles_to_sub(ev, X, output_file, video_begin_time, separator)
    elif output_file.endswith('.usf'):
        OF_subtitles.of_subtitles_to_usf(ev, X, output_file, video_begin_time, separator)


if __name__ == '__main__':

    debug = False

    if debug:

        bin_file = r'C:\Users\jerome\Dropbox\wild_cog_2017-18\data\H1\3_gonogo_one\P7\OF_38\19_03_18\EV180309.BIN'
        events_file = r'D:\github\openfeeder\software\misc\events\OF_events_20180306.txt'
        subtitles_file = r'D:\github\openfeeder\software\misc\subtitles\OF_subtitles_test_01.txt'

    else:

        root = Tk()
        root.withdraw()

        bin_file = filedialog.askopenfilename(initialdir="/",
                                              title="Select file",
                                              filetypes=[("BIN files", "*.BIN")])

        if bin_file == '':
            sys.exit()

        events_file = filedialog.askopenfilename(initialdir="/",
                                                 title="Select file",
                                                 filetypes=[("txt files", "*.txt")])

        if events_file == '':
            sys.exit()

    ev, X = of_events_raw_read(bin_file, events_file)

    for n in range(0, len(ev), 4):
        print('{:02d}:{:02d}:{:02d} {}'.format(ev[n],
                                               ev[n+1],
                                               ev[n+2],
                                               X[ev[n+3]-1]))

    if not debug:

        subtitles_file = filedialog.askopenfilename(initialdir="/",
                                                    title="Select file",
                                                    filetypes=[("txt files", "*.txt")])

        if subtitles_file == '':
            sys.exit()

        root.destroy()

    ev, X = of_events_readable_read(bin_file, subtitles_file)

    for n in range(0, len(ev), 4):
        print('{:02d}:{:02d}:{:02d} {}'.format(ev[n],
                                               ev[n+1],
                                               ev[n+2],
                                               X[ev[n+3]-1]))

    if platform.system() == 'Windows':
        srt_file = os.path.join(os.getenv('USERPROFILE'), 'Desktop', 'OF_subtitles_Python.srt')
    else:
        srt_file = os.path.join('~/Desktop', 'Desktop', 'OF_subtitles_Python.srt')

    usf_file = srt_file.replace('.srt', '.usf')
    sub_file = srt_file.replace('.srt', '.sub')

    separator = ','

    of_events_to_subtitles(bin_file, subtitles_file, srt_file, None, separator)
    of_events_to_subtitles(bin_file, subtitles_file, usf_file, None, separator)
    of_events_to_subtitles(bin_file, subtitles_file, sub_file, None, separator)
