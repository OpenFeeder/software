# -*- coding: utf-8 -*-
"""
Created on Mon Sep  3 15:06:04 2018

@author: jerome
"""

from tkinter import Tk, filedialog
import sys


def of_events_to_txt(bin_file, events_file, text_file, separator=';'):

    ev, X = of_events_read(bin_file, events_file)

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


def of_events_read(bin_file, events_file):

    file = open(bin_file, 'rb')
    ev = file.read()
    file.close()

    file = open(events_file, 'r')
    X = file.read().splitlines()
    file.close()

    return ev, X


if __name__ == '__main__':

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

    text_file = filedialog.asksaveasfilename(initialdir="/",
                                             title="Select file",
                                             filetypes=[("txt files", "*.txt")])

    if text_file == '':
        sys.exit()

    root.destroy()

    of_events_to_txt(bin_file, events_file, text_file, ';')
