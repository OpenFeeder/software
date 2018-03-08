# -*- coding: utf-8 -*-
"""
@author: Jerome Briot
"""

import serial
import sys
import math

import datetime

delay = 0.15

num = 12

serialPort = "COM36"

ser = serial.Serial(port=None, baudrate=9600, timeout=1, writeTimeout=1)

ser.port = serialPort

try:

    ser.open()

except serial.SerialException as e:

    print(e)
    sys.exit(1)

for n in range(0, 2):

    # Query PC date and time
    PC_time = datetime.datetime.now()

    # Dont synchronize OF date and time during the first iteration to allow offsets computation
    if n > 0:
        # Synchronize OF date and time with PC date and time
        b = bytes([83, PC_time.year-2000, PC_time.month, PC_time.day, PC_time.hour, PC_time.minute, PC_time.second])
        ser.write(b)

    # Query OF date and time
    ser.write(b'T')
    while ser.in_waiting < num:
        pass
    OF_time = ser.read(num)

    # Check if external RTC module is available
    if OF_time[6] == 0 and OF_time[7] == 0 and OF_time[8] == 0 and OF_time[9] == 0 and OF_time[10] == 0 and OF_time[11] == 0:
        ext_rtc_available = False
    else:
        ext_rtc_available = True

    # Print dates and times in the console
    print("\nPC : {:02d}/{:02d}/20{:02d} {:02d}:{:02d}:{:02d}".format(PC_time.day, PC_time.month, PC_time.year-2000, PC_time.hour, PC_time.minute, PC_time.second))
    print("PIC: {:02d}/{:02d}/20{:02d} {:02d}:{:02d}:{:02d}".format(OF_time[2], OF_time[1], OF_time[0], OF_time[3], OF_time[4], OF_time[5]))
    if ext_rtc_available:
        print("EXT: {:02d}/{:02d}/20{:02d} {:02d}:{:02d}:{:02d}".format(OF_time[8], OF_time[7], OF_time[6], OF_time[9], OF_time[10], OF_time[11]))
    else:
        print("EXT: --/--/---- --:--:--")

    # Compute offset between PC and PIC date and time
    PIC_time = datetime.datetime(OF_time[0]+2000, OF_time[1], OF_time[2], OF_time[3], OF_time[4], OF_time[5])

    if PC_time > PIC_time:
        delta = PC_time-PIC_time
        sign = '+'
    else:
        delta = PIC_time-PC_time
        sign = '-'

    if delta.days < 1:

        h = math.floor(delta.seconds/(60*60))
        m = math.floor((delta.seconds-h*60*60)/60)
        s = math.floor(delta.seconds-h*60*60-m*60)
        cs = math.floor(delta.microseconds/1000)

        print("\nDiff PC-PIC: {}{:02d}:{:02d}:{:02d}.{:03d} ({}, {}, {} | {})".format(sign, h, m, s, cs, delta.days, delta.seconds, delta.microseconds, delta.total_seconds()))

    else:
        print("\nDiff PC-PIC: greater than one day ({} days and {} seconds)".format(delta.days, delta.seconds))

    # Compute offset between PC and external module date and time (if available)
    if ext_rtc_available:

        EXT_time = datetime.datetime(OF_time[6]+2000, OF_time[7], OF_time[8], OF_time[9], OF_time[10], OF_time[11])

        if PC_time > EXT_time:
            delta = PC_time-EXT_time
            sign = '+'
        else:
            delta = EXT_time-PC_time
            sign = '-'

        if delta.days < 1:

            h = math.floor(delta.seconds/(60*60))
            m = math.floor((delta.seconds-h*60*60)/60)
            s = math.floor(delta.seconds-h*60*60-m*60)
            cs = math.floor(delta.microseconds/1000)

            print("Diff PC-EXT: {}{:02d}:{:02d}:{:02d}.{:03d} ({}, {}, {} | {})".format(sign, h, m, s, cs, delta.days, delta.seconds, delta.microseconds, delta.total_seconds()))

        else:
            print("Diff PC-EXT: greater than one day ({} days and {} seconds)".format(delta.days, delta.seconds))

    else:
        print("Diff PC-EXT:  --:--:--.--- (0, 0, 0, | 0)")

ser.close()
