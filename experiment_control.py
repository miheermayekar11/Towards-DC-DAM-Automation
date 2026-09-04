'''
DAM OOK experiment control
KS
1.26.2017
v2 : uses new scope, captures startup time and data is user-defined bit sequence
JD 1.23.2023

DESCRIPTION:
################################################################################
this is a program to generate test inputs and measure outputs of DAM and
conventional OOK systems.

USE:
################################################################################
1.  connect AWG and DPO to computer via ethernet hub

1a. optional: check addresses match those in hwi.py using MATLAB's "tmtool")

2.  open a command prompt (cmd.exe) and navigate to the folder containing this
    script

2a. optional: test the hardware library by running
    > python ../hardware-functions/hwi.py

3.  connect AWG outputs and DPO inputs as described in the table below

4.  set signal, scope, saving, and plotting options in the section bounded by
    "begin..." and "end user defined settings"

5.  execute the program by running:
    > python ook_main.py

CONNECTIONS:
################################################################################
awg output          connect to              description
--------------------------------------------------------------------------
CH1 +               RF in of DOT            RF signal, modulated or CW
CH1 M1 +            switch Vin              Vin switch control signal
CH1 M1 -            copy of switch Vin      
CH1 M2 +            baseband data           scope channel 3
CH2 M1 +                                    
CH2 M2 +            trigger signal          scope channel 4
CH2 +               IDEAL WF COPY for MF    scope channel 2
'''
#########################################
## setup
#########################################
import sys, random
from datetime import datetime
import numpy
import scipy.io as sio
from hwi import *
from signalsynthesis_230125 import * #comment out _230235 for original file if not using demo
from signalsynthesis_alt_qpsk import * #Use for bpsk and qpsk
import os, shutil
###############################################################################
# BEGIN USER-DEFINED SETTINGS
###############################################################################
## HIGH LEVEL FLAGS & CTRL
#########################################
plottesting = 0                 # flag for turning off awg commands
awgonly = 0                     # flag for turning off dpo commands
exttrig = 0                     # sets awg to external triggering (10Hz GPSDO)
ch1ch4only = 0;                 # save the dpo channel 1 and 4 only (use this)
savesignal = 1;                 # save awg data (use this)
savedata = 1;                   # flag for saving data
savetag = 'DAM';             # filename tag
attenuator = 10;		# name tag
today = datetime.now()
savedir_date = today.strftime('%Y%m%d')
measurements_folder = '/measurements/';
dpo_folder = 'dpo/';
awg_folder = 'awg/';
vdc_est=1;
savedir_loc = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date; #'D:/DATA/'; #External Drive in this case its COOPER
path_date = os.path.join(savedir_loc)
try:
 os.mkdir(path_date)
except FileExistsError:

 savedir_loc = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder; #'D:/DATA/'; #External Drive in this case its COOPER
 path_measurements = os.path.join(savedir_loc)
 try:
  os.mkdir(path_measurements)
 except FileExistsError: 

  savedir_loc_awg = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+awg_folder; #'D:/DATA/'; #External Drive in this case its COOPER
  path_awg = os.path.join(savedir_loc_awg)
  try:
   os.mkdir(path_awg)
  except FileExistsError:  

   savedir_loc_dpo = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+dpo_folder; #'D:/DATA/'; #External Drive in this case its COOPER
   path_dpo = os.path.join(savedir_loc_dpo)
   try:
    os.mkdir(path_dpo)
   except FileExistsError:
       # if os.path.isdir('C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+dpo_folder):
       #    shutil.rmtree('C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+dpo_folder)
       #    savedir_loc_dpo = 'C:/Users/mpmayeka/Desktop/DATA/'+savedir_date+measurements_folder+dpo_folder; #'D:/DATA/'; #External Drive in this case its COOPER
       #    path_dpo = os.path.join(savedir_loc_dpo)
       #    os.mkdir(path_dpo)
       #    savedir_dpo = savedir_loc_dpo
    savedir_awg = savedir_loc_awg #change '/measurements/' to '/phase finder/' if running phase finder
    savedir_dpo = savedir_loc_dpo
#########################################
## GENERAL SIGNAL SETTINGS
#########################################
fc = 26.91e6 #26.11e6;#30e6;#26.566e6;#26.76e6;               # carrier frequency
os = 30;                 # awg oversampling rate samples/cycle
repeatlength = 1;       # number of times to repeat sequence (50)
channel_sound_enable = 0; # use for outdoor measurements
marker_amplitude = 1.2;
modulation = 'ook'      #bpsk, qpsk, ook
method = 'dam';          # modulation method ('cw', 'dam', or 'conv')
type_of_switch = 'adg919'# 'adg902', 'hmc550a', 'adg919': allows condition to set unique bias conditions
num_of_switch = 1;
N_ = [20]                  # number of cycles / symbol
N = N_[0]                  # neccessary for sweeping N_
fsymbol = fc/N
print('symbol frequency',fsymbol)
PHI = [110] #[130]#'sweep'#[70]      # degrees offset (can be array)
startupbits = 25;         # number of startup bits
numbits = 128;           # number of data bits
bitmode = 'prbs'        # either 'prbs' (prbs required for qpsk) or '1010' or 'demo' (only in conjuction with DAM)

ydiv = 0.1;        # scope vertical scaling factor
DC_marker_amplitude = [1.0] # this can be used for DC assisted or as an additional marker on the awg
diff_phi_transitions = 0

if diff_phi_transitions:
    phi_90 = 10
    phi_180 = 40
    phi_270 = 40

if type_of_switch == 'adg902':
    am1=1.2; #amplitude of marker1
    am2=1.2; #amplitude of marker2 

elif type_of_switch == 'hmc550a':
    am1=1.2; #amplitude of marker1
    am2=1.2; #amplitude of marker2

elif type_of_switch == 'adg919':
    am1=1.2; #amplitude of marker1
    am2=1.2; #Use this to set DC assisted bias of 919

#########################################
## Scope Settings (AVERAGING)
#########################################
navg = 30;        # number of averaging cycles
nom_samprate = 5e9; #sets the sample rate of the awg
os_awg = round(1/fc*nom_samprate); # samples a cycle
os_dpo = 30;      # nominal samples / cycle on dpo
dr = 1/((1/fc)*N)
print('raw datarate',dr/1e6,'mbps');

samples_cycle = (1/fc)*nom_samprate
samples_bit = samples_cycle*N
total_samples = (2*startupbits+numbits)*samples_bit



################################################################################
# END USER-DEFINED SETTINGS
################################################################################
if modulation=='bpsk':
    M = 2
elif modulation=='qpsk':
    M = 16;
else:
    M = 0;
    
#########################################
## ADJUST FOR PHASE SWEEP
#########################################
if PHI=="sweep":
    PHI = numpy.arange(0,360,10);

if DC_marker_amplitude=="sweep":
    DC_marker_amplitude = numpy.arange(0,50,1);
    DC_marker_amplitude = DC_marker_amplitude/100

#########################################
## MAKE BITSEQUENCE
#########################################
if modulation=='ook':
    bitseq ,startupbits = make_ook_bitseq(bitmode,numbits,startupbits)
elif (modulation=='bpsk') or (modulation=='qpsk'):
    bitseq, startupbits = make_mpsk_bitseq(M,bitmode,numbits,startupbits)
else:
    raise RuntimeError('invalid modulation scheme')

#########################################
## HARDWARE SETUP
########################################
# THESE FUNCTIONS ARE DEFINED IN THE HWI.PY FILE
lprint('setup...'); print ('')
if not plottesting:
# connect to awg
    lprint('\tconnecting to awg')
    try:
        awg = connect_to_awg70002a(reset=0,showid=1);
    except:
        arduino.close()
        rprint('failed.')
        raise RuntimeError("failed to connect to awg")
       
# connect to dpo
if not awgonly:
    lprint('\tconnecting to dpo')
    try:
        dpo = connect_to_dpo70404c(reset=1,showid=1);
    except:
        arduino.close()
        rprint('failed.')
        raise RuntimeError("failed to connect to dpo")
        arduino.close()

#########################################
## MAIN PROGRAM
#########################################
now = time.strftime("%Y%m%d-%H%M%S")
for N in N_:
	print('Setting Datarate to',N)
	## CHIRP SETTINGS 
	#########################################
	fbw = 1.25;                 # fractional bandwidth of chirp
	numcycles = (2*startupbits+numbits)*N;           # nominal number of center frequency cycles in chirp
	for dc_marker_amplitude in DC_marker_amplitude:
	    for phi in PHI:
	        print ('')
	        lprint('running measurement...'); print ('')
	        lprint('\tmethod:'); print ('%s' % method)
	        lprint('\tphi:'); print ('%s' % phi)
	        lprint('\tdc amplitude:'); print ('%s' % dc_marker_amplitude)
	        lprint('\tbitmode:'); print ('%s' % bitmode)
	        lprint('\tfirst ten bits:'); print ('%s' % bitseq[0:10])
	        lprint('\trepeat:'); print ('%s' % repeatlength)

	        # calculate clock rate, check if below AWG spec
	        fs = check_awg_rate(fc,os)

	        # calculate dpo sampling rate, and check if below spec
	        samprate = os_dpo*fc; # nominal sample rate
	        numpts = repeatlength*((numbits+startupbits*2)*N+numcycles)*os_dpo;   # nominal number of acquisition points
	        #numpts = num_symbols*nom_samprate/fsymbol;   # nominal number of acquisition points
	        if samprate>25e9:
	            raise RuntimeError('dpo sampling rate > 25 GHz, lower carrier frequency or oversampling rate')

	        lprint('\tdata points to awg:'); print ('%0.0f' % total_samples)
	        lprint('\tgenerating awg signals'); print ('')

	        # make data signals
	        if modulation=='ook':
	            sigs_data = make_ook_signal(method,N,fc,os_dpo,phi,bitseq,numbits,startupbits,marker_amplitude)
	        elif ((modulation=='bpsk') or (modulation=='qpsk')) & (diff_phi_transitions == 0):
	            sigs_data = make_qpsk_919_sp2t_signal(M,method,N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude,dc_marker_always_on=False)
	        elif ((modulation=='bpsk') or (modulation=='qpsk')) & diff_phi_transitions :
	            sigs_data = make_qpsk_919_signal_diff_phi_transitions(M,method,N,fc,os,phi_90,phi_180,phi_270,bitseq,numbits,startupbits,marker_amplitude,dc_marker_always_on=False)
	        else:
	            raise RuntimeError('invalid modulation scheme')

	        # stack on chirp sounder preamble if needed
	        if channel_sound_enable:
	            d2 = [];
	            for i in range(0,len(sigs_data[3])):
	                sigs_data[3][i] = 0;
	            sigs_chirp = make_chirp_signal(numcycles,fbw,fc,os,marker_amplitude)
	            sigs_total = tile_and_stack(repeatlength,sigs_chirp,sigs_data)
	        else:
	            sigs_total = sigs_data
	            sig_length = len(sigs_total[4])

	        # unpack signals
	        y = sigs_total[4]
	        y2 = sigs_total[5]
	        m1 = sigs_total[0]
	        m2 = sigs_total[1]
	        d1 = sigs_total[2]
	        d2 = sigs_total[3]

	        if plottesting:
	            plt.figure()
	            plt.plot(y)
	            plt.figure()
	            plt.plot(m1)
	            plt.show()

	        if savesignal:
	            lprint('\tsaving awg signals'); print ("")
	            if diff_phi_transitions:
	                trans = 'phi90_%d_phi180_%d_phi270_%d' % (phi_90,phi_180,phi_270)
	            if diff_phi_transitions:
	                fid = '%s_%s_%s_%s_fc_%e_%s_N_%d_phi_%d_mode_%s_%ddB_dc_%sv_' % (now,'awg',savetag,modulation,fc,method,N,phi,bitmode,attenuator,dc_marker_amplitude);
	                sio.savemat(savedir_awg+fid+trans+'.mat',{'y':y,'m1':m1,'m2':m2,'d1':d1,'d2':d2,'N':N,'phi':phi,'fc':fc,'os':os,'startupbits':startupbits,'bitseq':bitseq,'repeatlength':repeatlength,'channel_sound_enable':channel_sound_enable,'fbw':fbw,'numcycles':numcycles})
	            else:
	                fid = '%s_%s_%s_%s_fc_%e_%s_N_%d_phi_%d_mode_%s_%ddB_dc_%sv' % (now,'awg',savetag,modulation,fc,method,N,phi,bitmode,attenuator,dc_marker_amplitude);
	                sio.savemat(savedir_awg+fid+'_'+type_of_switch+'.mat',{'y':y,'m1':m1,'m2':m2,'d1':d1,'d2':d2,'N':N,'phi':phi,'fc':fc,'os':os,'startupbits':startupbits,'bitseq':bitseq,'repeatlength':repeatlength,'channel_sound_enable':channel_sound_enable,'fbw':fbw,'numcycles':numcycles,'phi':phi})

	        # AWG CONFIGURATION DATA
	        ################################
	        if not plottesting:
	            y = sigs_total[4]
	            y2 = sigs_total[5]
	            m1 = sigs_total[0]
	            m2 = sigs_total[1]
	            if method == 'conv':
	                    if num_of_switch == 2:
	                        d1 = m1
	                    else:
	                        d1 = sigs_total[2]
	                        d2 = sigs_total[3]
	                        y2 = y
	                        m2 = d1
	            else:
	                d1 = sigs_total[2]
	                d2 = sigs_total[3]
	            lprint('\tresetting awg'); print ('')
	            awg.write('*RST')
	            time.sleep(2)
	            # setup triggering
	            if exttrig:
	                awg.write("SOURCE1:RMODE TRIG")
	                awg.write("SOURCE2:RMODE TRIG")
	                awg.write("SOURCE1:TINPut ATRigger")
	                awg.write("SOURCE2:TINPut ATRigger")
	                awg.write("Trigger:sequence:level 0.5")
	                dpo.write("CLOCK:SOURCE EFIXED")
	            # set clock speed on awg
	            lprint('\tsetting awg clock rate'); print ('')
	            awg.write('CLOCK:SRATE %0.5e' % fs)
	            # send data to awg
	            lprint('\ttransferring data to awg ch1'); print ('')
	            if marker_amplitude < 0:
	                m1_ = []
	                for x in m1:
	                    if x==0:
	                        m1_.append(1)
	                    else:
	                        m1_.append(0)
	                awg.send_data(channel=1,signal=y,marker1=m1_,marker2=m1_)
	                awg.write("SOURCE1:MARKer1:VOLTage:HIGH %0.5e" % 0)
	                awg.write("SOURCE1:MARKer1:VOLTage:LOW %0.5e" % marker_amplitude)
	            else:
	                awg.send_data(channel=1,signal=y,marker1=m1,marker2=m2)
	                awg.write("SOURCE1:MARKer1:VOLTage:HIGH %0.5e" % marker_amplitude) # <adjust amplitude here. better to use atten.!!
	            awg.enable_channel(1) 
	           
                # check whether to send marker or rf to ch2 output
	            lprint('\ttransferring data to awg ch2'); print ('')
	            awg.send_data(channel=2,signal=y2,marker1=d1,marker2=d2)
	            awg.write("SOURCE2:MARKer1:VOLTage:HIGH %0.5e" % dc_marker_amplitude)
	            if dc_marker_amplitude < 0.5:
	                dc_low = 0 #comment out if using DC Assist
	            else:
	                dc_low = 0
	            awg.write("SOURCE2:MARKer1:VOLTage:LOW %0.5e" % dc_low)
	            awg.enable_channel(2)

	            awg.write('SOURCE1:MARKER1:VOLTAGE:HIGH %eV' % am1)     #set up the voltage level of markers
	            awg.write('SOURCE1:MARKER2:VOLTAGE:HIGH %eV' % am2)
	            awg.write('SOURCE2:MARKER2:VOLTAGE:HIGH %eV' % am1)

	            # turn on awg
	            lprint('\tturning on awg output'); print ('')
	            awg.toggle_output('on')

	        # SCOPE SETUP
	        ################################
	        if not awgonly:
	            lprint('\tresetting dpo'); print ('')
	            dpo.write('*RST')
	            time.sleep(2)
	            lprint('\tconfiguring dpo'); print ('')
	            # enable channel 1 on dpo and set scaling
	            #dpo.write('ZOO:STATE ON');
	            dpo.write('CH1:SCALE %e' % ydiv);
	            # enable channel 2 on dpo and set scaling
	            dpo.write('SEL:CH2 ON')
	            dpo.write('CH2:SCALE 0.03')
	            dpo.write('CH2:TER 50')
	            # enable channel 3 on dpo and set scaling
	            dpo.write('SEL:CH3 ON')
	            dpo.write('CH3:SCALE 1')
	            dpo.write('CH3:TER 50')
	            # enable channel 4 on dpo and set scaling
	            dpo.write('SEL:CH4 ON')
	            dpo.write('CH4:SCALE 1')
	            dpo.write('CH4:TER 50')
	            # set trigger to channel 4, 0.5 V level
	            dpo.write('TRIGGER:A:EDGE:SOURCE CH4')
	            dpo.write('TRIGGER:A:LEVEL 0.5')
	            # set external 10 MHz reference
	            dpo.write("CLOCK:SOURCE EFIXED")
	            if exttrig:
	                dpo.write("ROSC:SOURCE EXTERNAL")
	            # set horizontal scale (this needs to be here, does nothing but breaks program if removed ??)
	            dpo.write('HORIZONTAL:SCALE %e' % 0.32e-6)
	            ## SET SAMPLING RATE
	            #[ a note on the sampling rate: the record length can be set arbitrarily, but the sampling rate can only be
	            # one of a fixed set of values determined by the dpo.  here the specified sampling rate is sent in, and the
	            # dpo picks the closest value.  the record length is then adjusted to span the appropriate time.  an additional
	            # 10% is then added so the record length includes some margin, including a second trigger pulse.]
	            dpo.write('HORIZONTAL:MODE:SAMPLERATE %e' % samprate)
	            lprint('\tcalculated sample rate:')
	            rprint('%e' % samprate)
	            lprint('\tdpo sample rate:')
	            dpo_sr = (dpo.query('HORIZONTAL:MODE:SAMPLERATE?'))
	            print(dpo_sr)
	            dpo_sr = [s for s in dpo_sr.split() ]
	            dpo_sr = float(dpo_sr[0])
	            if dpo_sr<samprate:
	                print('%e <- warning! dpo value lower than specification' % dpo_sr)
	            else:
	                rprint('%e' % dpo_sr)
	            # set dpo record length (see note above)
	            lprint('\tadjusted dpo record length:')
	            rprint('%e' % floor(numpts*dpo_sr/samprate*1.1)),
	            dpo.write('HORIZONTAL:MODE:RECORDLENGTH %e' % floor(numpts*dpo_sr/samprate*1.1))
	            # reformat positioning 
	            dpo.write('HORIZONTAL:MAIN:POSITION 0.500e+1')
	            lprint('\twaiting for dpo averaging'); print ('')
	            # make sure all the above commands actually happened
	            dpo.query('*OPC?')
	            # set DPO to average and wait until done
	            if navg!=0:
	                dpo.write('ACQUIRE:MODE AVERAGE')
	                dpo.write('ACQUIRE:NUMAVG %e' % navg)
	            starting_acquisitions = (dpo.query('ACQuire:NUMACq?'))
	            print(starting_acquisitions)
	            starting_acquisitions = [s for s in starting_acquisitions.split() ]
	            starting_acquisitions = float(starting_acquisitions[0])

	            completed_acquisitions = (dpo.query('ACQuire:NUMACq?'))
	            completed_acquisitions = [s for s in completed_acquisitions.split() ]
	            completed_acquisitions = float(completed_acquisitions[0])-starting_acquisitions
	            while completed_acquisitions<(navg):
	                completed_acquisitions = (dpo.query('ACQuire:NUMACq?'))
	                completed_acquisitions = [s for s in completed_acquisitions.split() ]
	                completed_acquisitions = float(completed_acquisitions[0])-starting_acquisitions
	                #lprint('\r\tcompleted aquisitions'); print (' %i/%i' % (completed_acquisitions,navg)),
	            time.sleep(5)
	            print ('')
                # SCOPE VIEW SETTINGS
                ################################
	            dpo.write('ZOOM:STATE ON')
	            if bitmode == 'demo':
	               dpo.write('ZOOM:HORIZONTAL:POSITION 73')
	               dpo.write('ZOOM:HORIZONTAL:SCALE 100')
	            else:
	               dpo.write('ZOOM:HORIZONTAL:POSITION 57')
	               dpo.write('ZOOM:HORIZONTAL:SCALE 100')
                    
	            # GET AND SAVE SCOPE DATA
	            ################################
	            if savedata:
	                lprint('\tfetching data from dpo'); print ('')
	                [pre1, data1] = dpo.fetch_data(1,floor(numpts*dpo_sr/samprate*1.1));
	                t1, y1 = parse_data_dpo70404c(pre1,data1);
	                if not ch1ch4only:
	                    [pre2, data2] = dpo.fetch_data(2,floor(numpts*dpo_sr/samprate*1.1));
	                    [pre3, data3] = dpo.fetch_data(3,floor(numpts*dpo_sr/samprate*1.1));
	                    t2, y2 = parse_data_dpo70404c(pre2,data2);
	                    t3, y3 = parse_data_dpo70404c(pre3,data3);
	                else:
	                    pre2 = "";
	                    t2 = 0;
	                    y2 = 0;
	                    pre3 = "";
	                    t3 = 0;
	                    y3 = 0;
	                [pre4, data4] = dpo.fetch_data(4,floor(numpts*dpo_sr/samprate*1.1));
	                t4, y4 = parse_data_dpo70404c(pre4,data4);
	                lprint('\tsaving fetched data'); print ('')
	                if diff_phi_transitions:
	                    trans = 'phi90_%d_phi180_%d_phi270_%d' % (phi_90,phi_180,phi_270)
	                if diff_phi_transitions:
	                    fid = '%s_%s_%s_%s_fc_%e_%s_N_%d_phi_%d_mode_%s_%ddB_dc_%sv_' % (now,'dpo',savetag,modulation,fc,method,N,phi,bitmode,attenuator,dc_marker_amplitude);
	                    sio.savemat(savedir_dpo+type_of_switch+fid+trans+'.mat',{'os':os_dpo,'pre1':pre1,'pre2':pre2,'pre3':pre3,'pre4':pre4,'t1':t1,'t2':t2,'t3':t3,'t4':t4,'y1':y1,'y2':y2,'y3':y3,'y4':y4,'N':N,'phi':phi,'fc':fc,'startupbits':startupbits,'bitseq':bitseq,'repeatlength':repeatlength,'channel_sound_enable':channel_sound_enable,'fbw':fbw,'numcycles':numcycles})
	                else:
	                    fid = '%s_%s_%s_%s_fc_%e_%s_N_%d_phi_%d_mode_%s_%ddB_dc_%sv' % (now,'dpo',savetag,modulation,fc,method,N,phi,bitmode,attenuator,dc_marker_amplitude);
	                    sio.savemat(savedir_dpo+fid+'_'+type_of_switch+'.mat',{'os':os_dpo,'pre1':pre1,'pre2':pre2,'pre3':pre3,'pre4':pre4,'t1':t1,'t2':t2,'t3':t3,'t4':t4,'y1':y1,'y2':y2,'y3':y3,'y4':y4,'N':N,'phi':phi,'fc':fc,'startupbits':startupbits,'bitseq':bitseq,'repeatlength':repeatlength,'channel_sound_enable':channel_sound_enable,'fbw':fbw,'numcycles':numcycles})


	    lprint('\tcomplete.'); print ('')


awg.close()
dpo.close()
