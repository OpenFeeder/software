# -*- coding: utf-8 -*-
"""
Created on Wed Dec  6 09:50:33 2017

@author: Jerome Briot
"""

import serial
import sys
import time
import math

import datetime

delay = 0.15

serialPort = "COM36"

ser = serial.Serial(port=None, baudrate=9600, timeout=1, writeTimeout=1)

ser.port = serialPort

try:

    ser.open()

except serial.SerialException as e:

    print(e)
    sys.exit(1)

ligne = ser.read_all()

ser.write(b't')

#current_time = time.localtime()
current_time = datetime.datetime.now()

time.sleep(delay)

ligne = ser.read_all()

pic_date_str = ligne[:-28].decode("utf-8")
rtc_ext_str = ligne[26:50].decode("utf-8")

if rtc_ext_str[5]=='-':
    ext_rtc_available = False
else:
    ext_rtc_available = True

print("\nPC : {:02d}/{:02d}/20{:02d} {:02d}:{:02d}:{:02d}".format(current_time.day, current_time.month, current_time.year-2000, current_time.hour, current_time.minute, current_time.second))

print("{}\n{}".format(pic_date_str, rtc_ext_str))

pic_datetime = datetime.datetime(int(pic_date_str[11:15]), int(pic_date_str[8:10]), int(pic_date_str[5:7]), int(pic_date_str[16:18]), int(pic_date_str[19:21]), int(pic_date_str[22:24]))

delta = current_time-pic_datetime

if delta.days < 1:

    h = math.floor(delta.seconds/(60*60))
    m = math.floor((delta.seconds-h*60*60)/60)
    s = math.floor(delta.seconds-h*60*60-m*60)

    print("\nDiff PC-PIC: {:02d}:{:02d}:{:02d}".format(h, m, s))

else:

    print("\nDiff PC-PIC: greater than one day ({} days and {} seconds)".format(delta.days, delta.seconds))

if ext_rtc_available:

    rtc_ext_datetime = datetime.datetime(int(rtc_ext_str[11:15]), int(rtc_ext_str[8:10]), int(rtc_ext_str[5:7]), int(rtc_ext_str[16:18]), int(rtc_ext_str[19:21]), int(rtc_ext_str[22:24]))

    delta = current_time-rtc_ext_datetime

    if delta.days < 1:

        h = math.floor(delta.seconds/(60*60))
        m = math.floor((delta.seconds-h*60*60)/60)
        s = math.floor(delta.seconds-h*60*60-m*60)

        print("Diff PC-EXT: {:02d}:{:02d}:{:02d}".format(h, m, s))

    else:

        print("Diff PC-EXT: greater than one day ({} days and {} seconds)".format(delta.days, delta.seconds))

else:
    print("Diff PC-EXT: --:--:--")

ser.write(b's')

time.sleep(delay)
ligne = ser.read_all()

#current_time = time.localtime()
current_time = datetime.datetime.now()

b = bytes(str(current_time.day), 'ascii') + b'\r'
ser.write(b)
b = bytes(str(current_time.month), 'ascii') + b'\r'
ser.write(b)
b = bytes(str(current_time.year-2000), 'ascii') + b'\r'
ser.write(b)

time.sleep(delay)
ligne = ser.read_all()

b = bytes(str(current_time.hour), 'ascii') + b'\r'
ser.write(b)
b = bytes(str(current_time.minute), 'ascii') + b'\r'
ser.write(b)
b = bytes(str(current_time.second), 'ascii') + b'\r'
ser.write(b)

time.sleep(delay)
ligne = ser.read_all()

ligne = ser.read_all()
ligne = ser.read_all()
ligne = ser.read_all()

ser.close()
