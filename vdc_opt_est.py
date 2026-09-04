# -*- coding: utf-8 -*-
"""
Created on Thu Jun 13 19:53:55 2024

@author: mpmayeka
"""

import os
from datetime import datetime

today = datetime.now()
savedir_date = today.strftime('%Y%m%d')
measurements_folder = '/measurements/';
dpo_folder = 'dpo/';
awg_folder = 'awg/';

dc_est_folder = 'vdc_est/';
savedir_loc_dc_est = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+dpo_folder+dc_est_folder; #'D:/DATA/'; #External Drive in this case its COOPER
path_dc_est = os.path.join(savedir_loc_dc_est)

dc_opt_folder = 'dc_opt/';
savedir_loc_dc_opt = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+dpo_folder+dc_opt_folder;
path_dc_opt = os.path.join(savedir_loc_dc_opt)

def rename_directory(old_name, new_name):

    os.rename(old_name, new_name)

rename_directory(path_dc_est, path_dc_opt)