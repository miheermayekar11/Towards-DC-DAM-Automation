# -*- coding: utf-8 -*-
"""
Created on Wed Jun 12 15:29:37 2024

@author: mpmayeka
"""

import serial
import time
import struct
import signal
import sys
import subprocess
import os, shutil
import numpy

#num = 0;
arduino = serial.Serial(port='COM6',  baudrate=9600, timeout=1) #for BT module port='Outgoing port no.'
#inc_count = 0
#dec_count = 0
Inc = 1
Dec = 1


if os.path.isfile('C:/Users/mpmayeka/Desktop/DATA/file.txt'):
    os.remove('C:/Users/mpmayeka/Desktop/DATA/file.txt')


def write_read(Data):
    arduino.write(struct.pack('>B', Data)) #arduino.write(bytes(Data,'utf-8'))      
    time.sleep(1)
    data = arduino.readline()
    return  data

def write_read_inc(inc):
    arduino.write(struct.pack('>B', inc)) #arduino.write(bytes(Data,'utf-8'))      
    time.sleep(1)
    data = arduino.readline()
    return  data

def write_read_dec(dec):
    arduino.write(struct.pack('>B', dec)) #arduino.write(bytes(Data,'utf-8'))      
    time.sleep(1)
    data = arduino.readline()
    return  data

def write_read_iter(itr):
    arduino.write(struct.pack('>B', itr)) #arduino.write(bytes(Data,'utf-8'))      
    time.sleep(1)
    data = arduino.readline()
    return  data

# def handler(signum, frame):
#     res = input("Ctrl-c was pressed. Do you really want to exit? y/n ")
#     if res == 'y':
#        arduino.close()
#        sys.exit(0)
#     if res == 'n':
#        while True:
#            num_1=int(num)
#            #num = int(input("Enter DC Voltage: "))
           
#            #num_iter = int(input("Enter number no. of iterations: "))
#            inc_count = 0
#            dec_count = 0
#            value  = write_read(num_1)
#            #value_iter = write_read_iter(num_iter) 
#            #print(value.decode('utf')) #print(float(value)) #.decode('utf')
#            #subprocess.run(["python", "C:/Users/mpmayeka/Desktop/Python DAM experiment scripts/experiment_control.py"])
#            time.sleep(1)
           
#            while inc_count < 4: #number of times DC volatge increments
#                value_inc  = write_read_inc(Inc)
#                #print(value_inc.decode('utf'))
#                #subprocess.run(["python", "C:/Users/mpmayeka/Desktop/Python DAM experiment scripts/experiment_control.py"])
#                inc_count += 1
#                #time.sleep(1)
#            while dec_count < 4: #number of times DC volatge decrements
#                  value_dec  = write_read_dec(Dec)
#                  #print(value_dec.decode('utf'))
#                  #subprocess.run(["python", "C:/Users/mpmayeka/Desktop/Python DAM experiment scripts/experiment_control.py"])
#                  dec_count += 1
#                  #time.sleep(1) 
       
#signal.signal(signal.SIGINT, handler)

#while True:
#num=8;    
num_1 = int(num)
vdc_est=1;
data_bits_count=1;
    #num = int(input("Enter DC Voltage: "))
    
    #num_iter = int(input("Enter number no. of iterations: "))
#inc_count = 0
#dec_count = 0
value  = write_read(num_1)
    #value_iter = write_read_iter(num_iter)
f = open('C:/Users/mpmayeka/Desktop/DATA/DC voltage profile.txt', 'w')
print(value.decode('utf'), file=f)
f.close()
value_decoded = value.decode('utf')
try:
  value_decoded_int =float(value_decoded[33:39])
except:
    print("Something went wrong, check the DC voltage profile text file or reset the Arduino")
    arduino.close()
    sys.exit(0)
else:    
  value_decoded_int = round(value_decoded_int,1)
  if value_decoded_int <= num_1/10 or value_decoded_int >= num/10:
    #print(value.decode('utf')) #print(float(value)) #.decode('utf')
#os.system("C:/Users/mpmayeka/Desktop/Python DAM experiment scripts/experiment_control.py")

# data acquisition start###########################################################################

   with open("C:/Users/mpmayeka/Desktop/Python - MATLAB  automated DC DAM scripts-20240624T225745Z-001/Python - MATLAB  automated DC DAM scripts/Python DAM experiment scripts/experiment_control_current_realtime.py") as file:
     exec(file.read())
   
#data acquisition stop############################################################################################

  time.sleep(1)
  
arduino.close()
time.sleep(1)