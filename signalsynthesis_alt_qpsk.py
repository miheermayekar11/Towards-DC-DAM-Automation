'''
new version of signal synthesis scripts for testing different versions of
qpsk control
'''

## setup
#########################################
import sys, random
import numpy
import matplotlib.pyplot as plt
from math import *

# display utils
################################################################
def lprint(str):
	print("{0:<30}".format(str)),

def rprint(str):
	print("{0:<19}".format(str[0:19]))

def lineprint():
	print("{0:=>50}".format(""))

# actual signal synthesis
#################################################################
def make_qpsk_919_signal_diff_phi_transitions(M,method,N,fc,os,phi_90,phi_180,phi_270,bitseq,numbits,startupbits,marker_amplitude,dc_marker_always_on=False):

    # generate signal parameters and time series
    ################################
    samplespercycle = os
    samplespersymbol = samplespercycle*N
    symbolspersignal = 2*startupbits+numbits
    samplespersignal = samplespersymbol*symbolspersignal
    lprint('\tdata points to awg:'); #print ('%0.0f' % samplespersignal)
    lprint('\tgenerating awg signals'); #print ('')
    x = range(0,samplespersignal)

    # put together bit sequence with startup, bits, and shutdown
    bits = [0]*startupbits + bitseq + [0]*startupbits
    ps = [2*pi*float(bit)/float(M) for bit in bits]

    # make rf mask to turn off rf signal during shutdown
    rfmask = [1]*startupbits + [1]*numbits + [0]*startupbits

    # construct logic signals for vdd, trigger, and switch control
    vdc = [];
    vc = [];
    vtr = [];
    vrf = [];
    for i in range(symbolspersignal):
        # TRIGGER
        if (i == 0):
            vtr = vtr+[1]*samplespersymbol
            phi = phi_180
        else:
            vtr = vtr+[0]*samplespersymbol
            if (float(bits[i]) - float(bits[i-1])) == 0:
                phi = phi
            elif ((float(bits[i]) - float(bits[i-1])) == 1) or ((float(bits[i]) - float(bits[i-1])) == -3):
                phi = phi_90
            elif abs(float(bits[i]) - float(bits[i-1])) == 2:
                phi = phi_180
            elif ((float(bits[i]) - float(bits[i-1])) == 3) or ((float(bits[i]) - float(bits[i-1])) == -1):
                phi = phi_270
        # RF
        rfsymbol = [cos(2*pi*dx/os + phi*pi/180 - ps[i])*rfmask[i] for dx in range(0,samplespersymbol)]
        vrf = vrf+rfsymbol
        # SWITCH CONTROL
        VC = [1]*samplespersymbol
        VDC = [0]*samplespersymbol
        if i in range(1,len(ps)-1):
            if ps[i-1]!=ps[i]:
                for p in range(0,samplespersymbol):
                    if (float(p)/float(samplespercycle))<=(float(bits[i])/float(M)):
                        VC[p] = 0;
                        VDC[p]=1;
            if ps[i]!=ps[i+1]:
                for p in range(0,samplespersymbol):
                    if (float(samplespersymbol-p)/float(samplespercycle))<=(1-float(bits[i])/float(M)):
                        VC[p] = 0;
                        VDC[p]=1;


        vc = vc+VC
        if dc_marker_always_on:
            vdc = vdc+[1]*samplespersymbol
        else:
            vdc = vdc+VDC

    # setup data to send to awg
    ################################
    # channel 1: y1 = rf, m1 = vc, m2 = nothing
    # channel 2: y2 = trig, d1 = vdc, d1 = nothing
    m1 = []; m2 = []; d1 = []; d2 = []; y1 = []; y2 = [];
    if method=='dam':
        for i in range(0,len(vc)):
            m1.append(vc[i])
            m2.append(1)
            d1.append(1)
            #d1.append(vdc[i])
            d2.append(vtr[i])
            y1.append(vrf[i])
            y2.append(vtr[i])
    elif method=='conv':
        for i in range(0,len(vc)):
            m1.append(1)
            m2.append(1)
            d1.append(0)
            d2.append(vtr[i])
            y1.append(vrf[i])
            y2.append(vtr[i])
    else:
        raise RuntimeError('invalid method, options are ''dam'' or ''conv''')
    return m1, m2, d1, d2, y1, y2

def make_mpsk_bitseq(M,bitmode,numbits,startupbits):
    if bitmode=='prbs':
        random.seed(31090)
        bitseq = []
        for i in range(0,numbits):
            bitseq.append(random.randint(0,M-1));
    elif bitmode=='1010':
        if (numbits % M == 0):
            bitseq = list(range(0,M))*int(numbits/M)
            #startupbits = 0;
        else:
            raise RuntimeError('numbits must be multiple of M in 1010 bitmode')
    else:
        raise RuntimeError('possible bitmodes are ''1010'' and ''prbs''')

    return bitseq, startupbits

def make_qpsk_method_1_signal(M,method,N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude):
    # truth table for bit transitions.  should be symmetric.
    # in normal driven operation vc0 = vc1 = 0, and the switch routs the RF1 source to the antenna.
    # A = (vc0 = 1, vc1 = 0) and the switch routs the RF2 source to the antenna.
    # B = (vc0 = 0, vc1 = 1) and the switch routs the RF3 source to the antenna.
    TT = numpy.array([['','A','B','A'],
                      ['A','','A','B'],
                      ['B','A','','A'],
                      ['A','B','A','']])

    # generate signal parameters and time series
    ################################
    samplespercycle = os
    samplespersymbol = samplespercycle*N
    symbolspersignal = 2*startupbits+numbits
    samplespersignal = samplespersymbol*symbolspersignal
    lprint('\tdata points to awg:'); #print ('%0.0f' % samplespersignal)
    lprint('\tgenerating awg signals'); #print ('')
    x = range(0,samplespersignal)

    # put together bit sequence with startup, bits, and shutdown
    bits = [0]*startupbits + bitseq + [0]*startupbits
    ps = [2*pi*float(bit)/float(M) for bit in bits]

    # make rf mask to turn off rf signal during shutdown
    rfmask = [1]*startupbits + [1]*numbits + [0]*startupbits

    # construct logic signals for vdd, trigger, and switch control
    vdc0 = [];
    vdc1 = [];
    vc0 = [];
    vc1 = [];
    vtr = [];
    vrf = [];
    for i in range(symbolspersignal):
        # TRIGGER
        if (i == 0):
            vtr = vtr+[1]*samplespersymbol
        else:
            vtr = vtr+[0]*samplespersymbol
        # RF
        rfsymbol = [cos(2*pi*dx/os + phi*pi/180 - ps[i])*rfmask[i] for dx in range(0,samplespersymbol)]
        vrf = vrf+rfsymbol
        # SWITCH CONTROL
        VC0 = [0]*samplespersymbol
        VC1 = [0]*samplespersymbol
        if i in range(1,len(ps)-1):
            if ps[i-1]!=ps[i]:
                if TT[bits[i-1],bits[i]]=='A':
                    for p in range(0,samplespersymbol):
                        if (float(p)/float(samplespercycle))<=(float(bits[i])/float(M)):
                            VC0[p] = 1;
                elif TT[bits[i-1],bits[i]]=='B':
                    for p in range(0,samplespersymbol):
                        if (float(p)/float(samplespercycle))<=(float(bits[i])/float(M)):
                            VC1[p] = 1;
            if ps[i]!=ps[i+1]:
                if TT[bits[i],bits[i+1]]=='A':
                    for p in range(0,samplespersymbol):
                        if (float(samplespersymbol-p)/float(samplespercycle))<=(1-float(bits[i])/float(M)):
                            VC0[p] = 1;
                elif TT[bits[i],bits[i+1]]=='B':
                    for p in range(0,samplespersymbol):
                        if (float(samplespersymbol-p)/float(samplespercycle))<=(1-float(bits[i])/float(M)):
                            VC1[p] = 1;

        vc0 = vc0+VC0
        vc1 = vc1+VC1
        vdc0 = vdc0+VC0
        vdc1 = vdc1+VC1

    # setup data to send to awg
    ################################
    # channel 1: y1 = rf, m1 = vc0, m2 = vc1
    # channel 2: y2 = trig, d1 = vdc0, d2 = vdc1
    m1 = []; m2 = []; d1 = []; d2 = []; y1 = []; y2 = [];
    if method=='dam':
        for i in range(0,len(vc0)):
            m1.append(vc0[i])
            m2.append(vc1[i])
            d1.append(vdc0[i])
            d2.append(vdc1[i])
            y1.append(vrf[i])
            y2.append(vtr[i])
    elif method=='conv':
        for i in range(0,len(vc0)):
            m1.append(0)
            m2.append(0)
            d1.append(vdc0[i])
            d2.append(vdc1[i])
            y1.append(vrf[i])
            y2.append(vtr[i])
    else:
        raise RuntimeError('invalid method, options are ''dam'' or ''conv''')
    return m1, m2, d1, d2, y1, y2

def make_qpsk_919_sp2t_signal(M,method,N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude,dc_marker_always_on=False):

    # generate signal parameters and time series
    ################################
    samplespercycle = os
    samplespersymbol = samplespercycle*N
    symbolspersignal = 2*startupbits+numbits
    samplespersignal = samplespersymbol*symbolspersignal
    lprint('\tdata points to awg:'); #print ('%0.0f' % samplespersignal)
    lprint('\tgenerating awg signals'); #print ('')
    x = range(0,samplespersignal)

    # put together bit sequence with startup, bits, and shutdown
    bits = [0]*startupbits + bitseq + [0]*startupbits
    ps = [2*pi*float(bit)/float(M) for bit in bits]

    # make rf mask to turn off rf signal during shutdown
    rfmask = [1]*startupbits + [1]*numbits + [0]*startupbits

    # construct logic signals for vdd, trigger, and switch control
    vdc = [];
    vc = [];
    vtr = [];
    vrf = [];
    for i in range(symbolspersignal):
        # TRIGGER
        if (i == 0):
            vtr = vtr+[1]*samplespersymbol
        else:
            vtr = vtr+[0]*samplespersymbol
        # RF
        rfsymbol = [cos(2*pi*dx/os + phi*pi/180 - ps[i])*rfmask[i] for dx in range(0,samplespersymbol)]
        vrf = vrf+rfsymbol
        # SWITCH CONTROL
        VC = [1]*samplespersymbol
        VDC = [0]*samplespersymbol
        if i in range(1,len(ps)-1):
            if ps[i-1]!=ps[i]:
                for p in range(0,samplespersymbol):
                    if (float(p)/float(samplespercycle))<=(float(bits[i])/float(M)):
                        VC[p] = 0;
                        VDC[p]=1;
            if ps[i]!=ps[i+1]:
                for p in range(0,samplespersymbol):
                    if (float(samplespersymbol-p)/float(samplespercycle))<=(1-float(bits[i])/float(M)):
                        VC[p] = 0;
                        VDC[p]=1;

        vc = vc+VC
        if dc_marker_always_on:
            vdc = vdc+[1]*samplespersymbol
        else:
            vdc = vdc+VDC

    # setup data to send to awg
    ################################
    # channel 1: y1 = rf, m1 = vc, m2 = nothing
    # channel 2: y2 = trig, d1 = vdc, d1 = nothing
    m1 = []; m2 = []; d1 = []; d2 = []; y1 = []; y2 = [];
    if method=='dam':
        for i in range(0,len(vc)):
            m1.append(vc[i])
            m2.append(vc[i])
            #m2.append(1)
            d1.append(1)
            #d1.append(vdc[i])
            d2.append(vtr[i])
            y1.append(vrf[i])#*vc[i])
            y2.append(vtr[i])
    elif method=='conv':
        for i in range(0,len(vc)):
            m1.append(1)
            m2.append(1)
            d1.append(0)
            d2.append(vtr[i])
            y1.append(vrf[i])
            y2.append(vtr[i])
    else:
        raise RuntimeError('invalid method, options are ''dam'' or ''conv''')
    return m1, m2, d1, d2, y1, y2

################################################################################
# use the rest of this file as a sketchpad for prototyping new signal synthesis
# methods.  otherwise ignore it.
################################################################################
if __name__ == '__main__':
    print('')
    print('signalsynthesis.py')
    print('running module tests')
    lineprint()

    lprint('setting OOK signal properties ... '),

    ## set general properties
    #########################################
    fc = 27.12e6;               # carrier frequency
    os = 40;                 # awg oversampling rate
    repeatlength = 5;       # number of times to repeat sequence
    marker_amplitude = 1;

    ## set ook properties
    #########################################
    method = 'dam';          # modulation method ('cw', 'dam', or 'conv')
    N = 5;                   # number of cycles / symbol
    phi = 20#numpy.arange(-180,180,10);               # degrees offset (can be array)
    startupbits = 3;         # number of startup bits
    numbits = 16;           # number of data bits
    bitmode = 'prbs'        # either 'prbs' or '1010'

    ## set chirp properties
    #########################################
    fbw = 0.2;                 # fractional bandwidth of chirp
    numcycles = 3e2;           # nominal number of center frequency cycles in chirp

    ## make bitsequence
    #########################################
    bitseq, startupbits = make_mpsk_bitseq(4,bitmode,numbits,startupbits)
    print(bitseq)

    ## make signals using method 1
    #########################################
    sigs_ook = make_qpsk_919_sp2t_signal(4,method,N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude)

    plt.figure(1)
    plt.subplot(311)
    plt.plot(sigs_ook[4])
    plt.plot(sigs_ook[5])
    plt.legend(['Ch1 RF','Ch2 RF'])
    plt.title('dc_marker_always_on = False')

    plt.subplot(312)
    plt.plot(sigs_ook[0])
    plt.plot(sigs_ook[1])
    plt.legend(['Ch1 M1','Ch1 M2'])
    plt.ylim([-0.25,1.25])
    plt.grid()

    plt.subplot(313)
    plt.plot(sigs_ook[2])
    plt.plot(sigs_ook[3])
    plt.legend(['Ch2 M1','Ch2 M2'])
    plt.ylim([-0.25,1.25])
    plt.grid()
    plt.tight_layout()

    sigs_ook = make_qpsk_919_sp2t_signal(4,method,N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude,dc_marker_always_on=True)

    plt.figure(2)
    plt.subplot(311)
    plt.plot(sigs_ook[4])
    plt.plot(sigs_ook[5])
    plt.legend(['Ch1 RF','Ch2 RF'])
    plt.title('dc_marker_always_on = True')

    plt.subplot(312)
    plt.plot(sigs_ook[0])
    plt.plot(sigs_ook[1])
    plt.legend(['Ch1 M1','Ch1 M2'])
    plt.ylim([-0.25,1.25])
    plt.grid()

    plt.subplot(313)
    plt.plot(sigs_ook[2])
    plt.plot(sigs_ook[3])
    plt.legend(['Ch2 M1','Ch2 M2'])
    plt.ylim([-0.25,1.25])
    plt.grid()
    plt.tight_layout()

    plt.show()
