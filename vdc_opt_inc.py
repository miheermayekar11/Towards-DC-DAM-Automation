# -*- coding: utf-8 -*-
"""
Created on Thu Jun 13 18:32:58 2024

@author: mpmayeka
"""

import os
from datetime import datetime

increment=str(increment)
today = datetime.now()
savedir_date = today.strftime('%Y%m%d')
measurements_folder = '/measurements/';
dpo_folder = 'dpo/';
awg_folder = 'awg/';

dc_inc_folder = 'dc_inc_'+increment+'/';
savedir_loc_dc_inc = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+dpo_folder+dc_inc_folder;
path_dc_inc = os.path.join(savedir_loc_dc_inc)

dc_opt_folder = 'dc_opt/';
savedir_loc_dc_opt = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+dpo_folder+dc_opt_folder;
path_dc_opt = os.path.join(savedir_loc_dc_opt)

def rename_directory(old_name, new_name):

    os.rename(old_name, new_name)

rename_directory(path_dc_inc, path_dc_opt)