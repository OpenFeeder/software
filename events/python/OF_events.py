# -*- coding: utf-8 -*-
"""
Created on Mon Sep  3 15:06:04 2018

@author: jerome
"""

from tkinter import Tk, filedialog


def of_events_bin_to_txt(bin_file, event_file, text_file):

    ev, X = of_events_read_bin(bin_file, event_file)

    file = open(text_file, 'w')

    idx = 0
    for n in range(0, len(ev)//4):
        file.write('{:02d}:{:02d}:{:02d} {}\n'.format(ev[idx], ev[idx+1], ev[idx+2], X[ev[idx+3]-1]))
        idx += 4
    file.close()


def of_events_read_bin(bin_file, event_file):

    file = open(bin_file, 'rb')
    ev = file.read()
    file.close()

    file = open(event_file, 'r')
    X = file.read().splitlines()
    file.close()

    return ev, X


if __name__ == '__main__':

    root = Tk()
    root.withdraw()

    bin_file = filedialog.askopenfilename(initialdir="/",
                                          title="Select file",
                                          filetypes=[("BIN files", "*.BIN")])

    event_file = filedialog.askopenfilename(initialdir="/",
                                            title="Select file",
                                            filetypes=[("txt files", "*.txt")])

    text_file = filedialog.asksaveasfilename(initialdir="/",
                                             title="Select file",
                                             filetypes=[("txt files", "*.txt")])

    root.destroy()

    of_events_bin_to_txt(bin_file, event_file, text_file)
