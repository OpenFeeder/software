# -*- coding: utf-8 -*-
"""
Created on Wed Dec  6 09:50:33 2017

@author: Jerome Briot
"""

import serial
import time

delay = 0.03

serialPort = "COM36"

ser = serial.Serial(port=serialPort, baudrate=9600, timeout=1, writeTimeout=1)

if not ser.isOpen():

    ser.open()

ligne = ser.read_all()

ser.write(b't')

time.sleep(delay*5)

ligne = ser.read_all()

print('{}'.format(ligne.decode("utf-8")))

ser.write(b's')

time.sleep(delay*5)
ligne = ser.read_all()

current_time = time.localtime()

b = bytes(str(current_time.tm_mday), 'ascii') + b'\r'
ser.write(b)
b = bytes(str(current_time.tm_mon), 'ascii') + b'\r'
ser.write(b)
b = bytes(str(current_time.tm_year-2000), 'ascii') + b'\r'
ser.write(b)

time.sleep(delay*5)
ligne = ser.read_all()

b = bytes(str(current_time.tm_hour), 'ascii') + b'\r'
ser.write(b)
b = bytes(str(current_time.tm_min), 'ascii') + b'\r'
ser.write(b)
b = bytes(str(current_time.tm_sec), 'ascii') + b'\r'
ser.write(b)

time.sleep(delay*5)
ligne = ser.read_all()

ser.write(b't')
time.sleep(delay*5)
ligne = ser.read_all()

print('{}'.format(ligne.decode("utf-8")))

ser.close()
