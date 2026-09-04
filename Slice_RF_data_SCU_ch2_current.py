# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 11:21:32 2023
@author: jkdusenb
"""
import os, shutil
from os import listdir
from os.path import isfile, join
import scipy.io as sio
import pandas as pd
#import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime

def process_file(file_path):
    # LOAD MEASURED DATA
    dir1 = directory
    filename = file_path

    data = sio.loadmat(dir1+filename)

    # load measured antenna data
    y_rf = data['y2']
    t_rf = data['t2']

    # load recorded trigger data
    y_tr = data['y4']
    t_tr = data['t4']

    # Use trigger to slice data
    tr_min = np.min(y_tr)
    tr_max = np.max(y_tr)

    # round trigger for boolean indexing
    trigger = np.round(np.abs(y_tr))
    trigger_index = np.where(trigger == 1)
    trigger_index = trigger_index[1]
    tr_loc = []
    A = range(len(trigger_index))
    for i in A:
        if (trigger_index[i] - trigger_index[i - 1]) > 1:
            tr_loc.append(i)

    # slice data with trigger indices
    TR_loc_beg = trigger_index[0]
    TR_loc_end = (trigger_index[tr_loc[0]])

    # recorded RF NF data CH1
    yrf = y_rf[0, TR_loc_beg:TR_loc_end]
    trf = t_rf[0, TR_loc_beg:TR_loc_end]

    # recorded Trigger Data CH4
    ytr = y_tr[0, TR_loc_beg:TR_loc_end]
    ttr = t_tr[0, TR_loc_beg:TR_loc_end]

    # plotting the newly sliced data
    #plt.plot(trf, yrf)

    # save newly sliced data
    mdic = {"yrf": yrf, "trf": trf, "y_trigger": ytr, "t_trigger": ttr}
    filename_new = 'SLICED_' + filename
    dirslice = 'SLICED/' #SLICED
    os.mkdir(dir1+dirslice)
    sio.savemat(dir1+dirslice+filename_new, mdic)


# Specify sub directories as needed. 
#subdir1 = 'SEGMENTED_L/' #DAMIN, DAMOUT, SEGMENTED_L
#subdir2 = '1dB_sweep_PHI/' #19,16,14,11,9,6,4,1
#subdir3 = 'DAM/' #DAM or LTI
#directory = 'C:/Users/jkdusenb/Desktop/Dummy Transfer/power_and_phi_sweep/'+subdir1+subdir2+subdir3
# today = datetime.now()
# savedir_date = today.strftime('%Y%m%d')
# savedir_loc = 'D:/DATA/'; #External Drive in this case its COOPER
# directory = savedir_loc+savedir_date+'/measurements/'

if slice_est == 1:
    directory = savedir_loc_dc_est
    slice_est =0;
    
if inc_count >= 1:
   directory = savedir_loc_dc_inc 

if dec_count >= 1:
   directory = savedir_loc_dc_dec
   
# Get all files in the directory
files = [f for f in listdir(directory) if isfile(join(directory, f))]

# Process each file
for file in files:
    if file.endswith('.mat'):
        file_path = join(directory, file)
        process_file(file)
