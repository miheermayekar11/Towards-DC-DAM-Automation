'''
short switching gap experiment control
KS
5.13.2018
v2 : uses new scope, captures startup time and data is user-defined bit sequence

DESCRIPTION:
################################################################################
this is a program to test the effect of short hold times in DAM systems.

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
CH1 M1 -            copy of switch Vin      scope channel 2
CH1 M2 +            switch Vdd              switch power supply
CH2 M1 +            data stream             scope channel 3
CH2 M2 +            trigger signal          scope channel 4
n/a                 circuit measurement     scope channel 1
'''

## setup
#########################################
import sys, random
from datetime import datetime
import numpy
import scipy.io as sio
from hwi import *
from signalsynthesis_SG import *

################################################################################
# BEGIN USER-DEFINED SETTINGS
################################################################################

## high-level controls
#########################################
plottesting = 0					# flag for turning off awg commands
awgonly = 0                     # flag for turning off dpo commands
exttrig = 0                     # sets awg to external triggering (1Hz GPSDO)
ch1ch4only = 0;                 # save the dpo channel 1 and 4 only (use this)
savesignal = 1;                 # save awg data (use this)
savedata = 1;                   # flag for saving data
savetag =  'testing_phase_finder';   #'switch_mode_hmc197'#    # filename tag
today = datetime.now()
savedir_date = today.strftime('%Y%m%d')
savedir_loc = 'C:/Users/mpmayeka/Desktop/DATA/'; #'D:/DATA/'; #External Drive in this case its COOPER
savedir = savedir_loc+savedir_date+'/phase finder/'

## General Signal Settings
#########################################
mode = '1010'               #'driven'for shortgap, or '1010' or 'switch'for switchspeed, or 'hmc194'for shortgap hmc194 spesifically.
type = 'dam'                        #'dam' or 'conv'
fc = 26.91e6;#26.04153e6;#27.43e6;               # carrier frequency
os = 30;                 # awg oversampling rate
N_start = 50				# number of start-up bits
N_on = 20;                   # number of cycles / symbol on bits
N_off = 20;				# number of off bits
N_cooldown = 50			# number of cool down bits
startupbits = N_start;         # number of startup bits
if mode == 'hmc194':
    marker_amplitude = 1.4
elif mode == 'switch':
    marker_amplitude = 1.4
    fc = 1e8
    os = 30
    N_start = 300
elif mode == 'hmc':
    marker_amplitude = 1.4
else:
    marker_amplitude = 1.4

channel_sound_enable = 0
repeatlength = 1;       # number of times to repeat sequence (50)
DC = [0.0] #[0.5];#          #1.2 for 90, 0.7 for 270, 0.74 for 180
PHI = "sweep" #"sweep" #for two switches[40]for one switch#[20,160, 320, 340]               # degrees offset (can be array) 30 for adg902 26mhz, 40 for adg919 27mhz ~20 for hmc194 17mhz, 280 for 29mhz. 80 for hmc550 17mhz
PHI2 = [0]              #degrees offset for close the switch, 100 for hmc194 at 17mhz
phi2_change = 0
DT = [20]#"sweep"          #4.5 for hmc194 at 17mhz

## Scope Settings
#########################################
ydiv = 0.1;
ydiv_channel2 = 0.3
navg = 20;        # number of averaging cycles
os_dpo = 2*os;      # nominal samples / cycle on dpo

## Chirp Settings
#########################################
fbw = 1.25;                 # fractional bandwidth of chirp

## adjust v_dc for sweep
#########################################
if DC=="sweep":
    a = numpy.arange(5,15,1)
    DC = a/10;

## adjust phi for sweep
#########################################
if PHI=="sweep":
    PHI = numpy.arange(0,360,10);
    phi2_change = 0;
if PHI2=="sweep":
    PHI2 = numpy.arange(0,360,10);
    phi2_change = 1;
## adjust phi for sweep
#########################################
if DT=="sweep":
    b = numpy.arange(0,10,0.05);
    DT = b/100


################################################################################
# END USER-DEFINED SETTINGS
################################################################################


## hardware setup
########################################
# text output for running long experiments:
print('setup...'); print ('')
# connect to awg
if not plottesting:
	print('\tconnecting to awg')
	try:
	    awg = connect_to_awg70002a(reset=0,showid=1);
	except:
	    print('failed.')
	    raise RuntimeError("failed to connect to awg")
# connect to dpo
if not awgonly:
    print('\tconnecting to dpo')
    try:
        dpo = connect_to_dpo70404c(reset=0,showid=1);
    except:
        print('failed.')
        raise RuntimeError("failed to connect to dpo")

## main program
#########################################
now = time.strftime("%Y%m%d-%H%M%S")
for phi in PHI:
    for dc in DC:
        for dt in DT:
            for phi2 in PHI2:
                if phi2_change == 0:
                    phi2 = phi              #degrees offset for close the switch, 100 for hmc194 at 17mhz
                #elif dt == 0:
                #    phi2 = phi

                print ('')
                print('running measurement...'); print ('')
                print('\tphi:'); print ('%s' % phi)
                print('\tdc:'); print ('%s' % dc)
                print('\tphi2:'); print ('%s' % phi2)

                # calculate clock rate, check if below AWG spec
                fs = check_awg_rate(fc,os)
                bitseq = []
                print('\tgenerating awg signals'); print ('')
                sigs_data = [[],[],[],[],[],[]]
                #for dt in DT:
                if mode == "1010":
                    bitseq.extend([1]*int(numpy.ceil(N_start+4*dt+N_on)))
                elif mode == "switch":
                	bitseq.extend([1]*int(numpy.ceil(N_start)))
                elif mode == "driven_rceffect":
                    bitseq.extend([1]*int(numpy.ceil(N_start*2+(dt+N_on)*6)))
                else:
                    bitseq.extend([1]*int(numpy.ceil(N_start+dt+N_on)))
                # calculate dpo sampling rate, check if below spec
                samprate = os_dpo*fc; # nominal sample rate
                if samprate>25e9:
                    raise RuntimeError('dpo sampling rate > 25 GHz, lower carrier frequency or oversampling rate')

                sigs_data_1dt = make_diff_dt_signal(N_start,N_on,N_cooldown,os,dt,phi,phi2,mode,type)
                sigs_data[0].extend(sigs_data_1dt[0])
                sigs_data[1].extend(sigs_data_1dt[1])
                sigs_data[2].extend(sigs_data_1dt[2])
                sigs_data[3].extend(sigs_data_1dt[3])
                sigs_data[4].extend(sigs_data_1dt[4])
                sigs_data[5].extend(sigs_data_1dt[5])
                numpts = int(1*repeatlength*len(sigs_data[0]))   # nominal number of acquisition points
                print('\tdata points to awg:'); print ('%0.0f' % numpts)
                # stack on chirp sounder preamble if needed
                numcycles = numpts/repeatlength/os    # nominal number of center frequency cycles in chirp
                if channel_sound_enable:
                    d2 = [];
                    for i in range(0,len(sigs_data[3])):
                        sigs_data[3][i] = 0;
                    sigs_chirp = make_chirp_signal(numcycles,fbw,fc,os,marker_amplitude)
                    sigs_total = tile_and_stack(repeatlength,sigs_chirp,sigs_data)
                else:
                    for i in range(len(sigs_data_1dt),len(sigs_data[3])):
                        sigs_data[3][i] = 0;
                    sigs_total = sigs_data
                #print(numpts)
                #print(numcycles)
                if channel_sound_enable:
                    print('chirp / data same length?')
                    print(len(sigs_chirp[3]))
                    print(len(sigs_data[3]))
                if plottesting:
                    plt.figure()
                    plt.plot(sigs_total[0])
                    plt.plot(sigs_data[4])
                    plt.figure()
                    plt.plot(sigs_data[0])
                    plt.figure()
                    plt.plot(sigs_data_1dt[0])
                    plt.figure()
                    plt.plot(sigs_total[4])
                    plt.figure()
                    plt.plot(sigs_data[4])
                    plt.figure()
                    plt.plot(sigs_data_1dt[4])
                    plt.show()
                # unpack signals
                y = sigs_total[4]
                m1 = sigs_total[0]
                m2 = sigs_total[1]
                d1 = sigs_total[2]
                d2 = sigs_total[3]
                y2 = sigs_total[5]


                if savesignal:
                    lprint('\tsaving awg signals'); print ("")
                    fid = '%s_%s_%s_%s_%s_fc_%e_N_start_%d_N_cooldown_%d_dc_%s_phi_%s_phi2_%s_dt_%s' % (now,'awg',savetag,mode,type,fc,N_start,N_cooldown,dc,phi,phi2,dt);
                    sio.savemat(savedir+fid+'.mat',{'y':y,'m1':m1,'m2':m2,'d1':d1,'d2':d2,'N':1,'phi':0,'N_cooldown':N_cooldown,'fc':fc,'os':os,'dc':dc,'phi':phi,'startupbits':startupbits,'bitseq':bitseq,'repeatlength':repeatlength,'channel_sound_enable':channel_sound_enable,'fbw':fbw,'numcycles':numcycles})

                # awg configuration and data
                ################################

                if not plottesting:
                    print('\tresetting awg'); print ('')
                    awg.toggle_output('off')
                    awg.write('OUTPUT1:STATE OFF')
                    awg.write('OUTPUT2:STATE OFF')
                    awg.write('WLIST:WAVEFORM:DELETE "WFM1"')
                    awg.write('WLIST:WAVEFORM:DELETE "WFM2"')
                    time.sleep(2)
                    awg.write("CLOCK:SOURCE INTERNAL")
                    #awg.write("CLOCK:SOURCE EFIXED")
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
                        awg.send_data(channel=1,signal=y,marker1=m1_,marker2=m2)
                        awg.write("SOURCE1:MARKer1:VOLTage:HIGH %0.5e" % 0)
                        awg.write("SOURCE1:MARKer1:VOLTage:LOW %0.5e" % marker_amplitude)
                    else:
                        awg.send_data(channel=1,signal=y,marker1=m1,marker2=m2)
                        awg.write("SOURCE1:MARKer1:VOLTage:HIGH %0.5e" % marker_amplitude)
                        awg.write("SOURCE1:MARKer1:VOLTage:LOW %0.5e" % 0)
                        awg.write("SOURCE1:MARKer2:VOLTage:HIGH %0.5e" % marker_amplitude)
                        awg.write("SOURCE1:MARKer2:VOLTage:LOW %0.5e" % 0)
                    awg.enable_channel(1)                                     # <------- adjust amplitude here. better to use atten.!!
                    # check whether to send marker or rf to ch2 output
                    lprint('\ttransferring data to awg ch2'); print ('')
                    awg.send_data(channel=2,signal=y,marker1=d1,marker2=d2)

                    #awg.write('SOURCE1:MARKER1:VOLTAGE:HIGH %eV' % am1)     #set up the voltage level of markers
                    #awg.write('SOURCE1:MARKER2:VOLTAGE:HIGH %eV' % am2)
                    awg.write('SOURCE2:MARKER1:VOLTAGE:HIGH %eV' % dc)
                    if dc < 0.5:
                        dc_low = dc-0.5
                    else:
                        dc_low = 0
                    awg.write("SOURCE2:MARKer1:VOLTage:LOW %0.5e" % dc_low)

                    awg.enable_channel(2)

                    # turn on awg
                    lprint('\tturning on awg output'); print ('')
                    awg.toggle_output('on')

                # scope setup
                ################################
                if not awgonly:
                    lprint('\tresetting dpo'); print ('')
                    dpo.write('*RST')
                    time.sleep(2)
                    lprint('\tconfiguring dpo'); print ('')
                    # enable channel 1 on dpo and set scaling
                    dpo.write('CH1:SCALE %e' % ydiv);
                    # enable channel 2 on dpo and set scaling
                    dpo.write('SEL:CH2 ON')
                    dpo.write('CH2:SCALE %e' % ydiv_channel2);
                    #dpo.write('CH2:SCALE 1')
                    #dpo.write('CH2:TER 50')
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
                    dpo.write('HORIZONTAL:SCALE %e' % 1.6e-6)
                    # set sampling rate
                    # a note on the sampling rate: the record length can be set arbitrarily, but the sampling rate can only be
                    # one of a fixed set of calues determined by the dpo.  here the specified sampling rate is sent in, and the
                    # dpo picks the closest value.  the record length is then adjusted to span the appropriate time.  an additional
                    # 10% is then added so the record length includes some margin, including a second trigger pulse.
                    dpo.write('HORIZONTAL:MODE:SAMPLERATE %e' % samprate)
                    print('\tcalculated sample rate:')
                    print('%e' % samprate)
                    print('\tdpo sample rate:')
                    dpo_sr = float(dpo.query('HORIZONTAL:MODE:SAMPLERATE?').split(' ')[0])
                    if dpo_sr<samprate:
                        print('%e <- warning! dpo value lower than specification' % dpo_sr)
                    else:
                        print('%e' % dpo_sr)
                    # set dpo record length (see note above)
                    print('\tadjusted dpo record length:')
                    print('%e' % floor(numpts*dpo_sr/samprate*1.1)),
                    dpo.write('HORIZONTAL:MODE:RECORDLENGTH %e' % floor(numpts*dpo_sr/samprate*1.1))
                    # reformat positioning
                    dpo.write('HORIZONTAL:MAIN:POSITION 0.500e+1')
                    print('\twaiting for dpo averaging'); print ('')
                    # make sure all the above commands actually happened
                    dpo.query('*OPC?')
                    # set DPO to average and wait until done
                    if navg!=0:
                        dpo.write('ACQUIRE:MODE AVERAGE')
                        dpo.write('ACQUIRE:NUMAVG %e' % navg)
                    starting_acquisitions = float(dpo.query('ACQuire:NUMACq?').split(' ')[0])
                    completed_acquisitions = float(dpo.query('ACQuire:NUMACq?').split(' ')[0])-starting_acquisitions
                    while completed_acquisitions<(navg):
                        completed_acquisitions = float(dpo.query('ACQuire:NUMACq?').split(' ')[0])-starting_acquisitions
                    print('\r\tcompleted aquisitions'); print (' %i/%i' % (completed_acquisitions,navg)),
                    time.sleep(5)
                    print ("")

                    # if requested get and save data from scope
                    ################################
                    if savedata:
                        print('\tfetching data from dpo'); print ("")
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
                        print('\tsaving fetched data'); print ("")
                        fid = '%s_%s_%s_%s_%s_fc_%e_N_start_%d_N_cooldown_%d_dc_%s_phi_%s_phi2_%s_dt_%s' % (now,'dpo',savetag,mode,type,fc,N_start,N_cooldown,dc,phi,phi2,dt);
                        sio.savemat(savedir+fid+'.mat',{'os':os_dpo,'pre1':pre1,'pre2':pre2,'pre3':pre3,'pre4':pre4,'t1':t1,'t2':t2,'t3':t3,'t4':t4,'y1':y1,'y2':y2,'y3':y3,'y4':y4,'N':1,'phi':0,'fc':fc,'startupbits':startupbits,'bitseq':bitseq,'repeatlength':repeatlength,'channel_sound_enable':channel_sound_enable,'fbw':fbw,'numcycles':numcycles,'N_cooldown':N_cooldown,'N_on':N_on,'N_off':N_off,'fc':fc,'dc':dc})



    print('\tcomplete.'); print ("")

awg.close()
dpo.close()
