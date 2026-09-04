## setup
#########################################
import sys, random
import numpy
import scipy.io as sio
from hwi import *
import matplotlib.pyplot as plt

def make_diff_phase_signal_hmc194(N_start,N_off,N_on,N_cooldown,os,phi,mode):
    v_rf = [] # rf signal
    v_dd = [] # switch supply signal
    v_in = [] # switch control signal
    v_tr = [] # trigger signal
    v_dc = [] # antenna terminal dc source signal

    numpts = int(numpy.ceil(N_start+N_off+N_on+N_cooldown)*30)
    for i in range(numpts):
        dx = i/30.0
        if dx <= N_start:
            v_rf.append(numpy.cos(2*numpy.pi*dx + phi*numpy.pi/180))
            v_in.append(1)
            v_dd.append(0)
            v_tr.append(1)
            v_dc.append(0)
        elif dx <= N_start+N_off:
            v_rf.append(0)
            v_in.append(0)
            v_dd.append(1)
            v_tr.append(0)
            v_dc.append(0)
        elif dx <= N_start+N_on+N_off:
            v_rf.append(numpy.cos(2*numpy.pi*(dx-N_off)+ phi*numpy.pi/180))
            v_in.append(1)
            v_dd.append(0)
            v_tr.append(0)
            v_dc.append(0)
        else:
            v_rf.append(0)
            v_in.append(0)
            v_dd.append(1)
            v_tr.append(0)
            v_dc.append(0)


    m1 = []; m2 = []; d1 = []; d2 = []; y1 = [];y2 = [];
    for i in range(0,len(v_in)):
        m1.append(v_in[i])
        m2.append(v_dd[i])
        d1.append(v_dc[i])
        d2.append(v_tr[i])
        y1.append(v_rf[i])
        y2.append(v_tr[i])



    return m1, m2, d1, d2, y1, y2

def make_diff_phase_signal(N_start,N_off,N_on,N_cooldown,os,phi,mode):
    v_rf = [] # rf signal
    v_dd = [] # switch supply signal
    v_in = [] # switch control signal
    v_tr = [] # trigger signal
    v_dc = [] # antenna terminal dc source signal

    numpts = int(numpy.ceil(N_start+N_off+N_on+N_cooldown)*30)
    for i in range(numpts):
        dx = i/30.0
        if dx <= N_start:
            v_rf.append(numpy.cos(2*numpy.pi*dx + phi*numpy.pi/180))
            v_in.append(1)
            v_tr.append(1)
            v_dc.append(1)
        elif dx <= N_start+N_off:
            v_rf.append(0)
            v_in.append(0)
            v_tr.append(0)
            v_dc.append(1)
        elif dx <= N_start+N_on+N_off:
            v_rf.append(numpy.cos(2*numpy.pi*(dx-N_off)+ phi*numpy.pi/180))
            v_in.append(1)
            v_tr.append(0)
            v_dc.append(1)
        else:
            v_rf.append(0)
            v_in.append(1)
            v_tr.append(0)
            v_dc.append(0)
        v_dd.append(1)


    m1 = []; m2 = []; d1 = []; d2 = []; y1 = [];y2 = [];
    for i in range(0,len(v_in)):
        m1.append(v_in[i])
        m2.append(v_dd[i])
        d1.append(v_dc[i])
        d2.append(v_tr[i])
        y1.append(v_rf[i])
        y2.append(v_tr[i])


    return m1, m2, d1, d2, y1, y2

def make_switch_transients_short_gap_signal(M,N,os,phi,dt,mode):
    v_rf = [] # rf signal
    v_dd = [] # switch supply signal
    v_in = [] # switch control signal
    v_tr = [] # trigger signal
    v_dc = [] # antenna terminal dc source signal
    if mode=='decay':
        numpts = int(numpy.ceil(N+M+dt)*30)
        for i in range(numpts):
            dx = i/30.0
            if dx <= N:
                v_rf.append(numpy.cos(2*numpy.pi*dx + phi*numpy.pi/180))
                v_in.append(1)
                v_tr.append(1)
            elif dx <= N+dt:
                v_rf.append(0)
                v_in.append(0)
                v_tr.append(0)
            else:
                v_rf.append(0)
                v_in.append(1)
                v_tr.append(0)
            v_dd.append(1)
    elif mode=='driven':
        numpts = int(numpy.ceil(N+2*M+dt)*30)
        for i in range(numpts):
            dx = i/30.0
            if dx <= N:
                v_rf.append(numpy.cos(2*numpy.pi*dx + phi*numpy.pi/180))
                v_in.append(1)
                v_tr.append(1)
                v_dc.append(0)
            elif dx <= N+dt:
                v_rf.append(0)
                v_in.append(0)
                v_tr.append(0)
                v_dc.append(1)
            elif dx <= N+dt+M:
                v_rf.append(numpy.cos(2*numpy.pi*(dx-dt) + phi*numpy.pi/180))
                v_in.append(1)
                v_tr.append(0)
                v_dc.append(0)
            else:
                v_rf.append(0)
                v_in.append(1)
                v_tr.append(0)
                v_dc.append(0)
            v_dd.append(1)
    elif mode=='conv':
        numpts = int(numpy.ceil(N+2*M+dt)*30)
        for i in range(numpts):
            dx = i/30.0
            if dx <= N:
                v_rf.append(numpy.cos(2*numpy.pi*dx + phi*numpy.pi/180))
                v_tr.append(1)
                v_dc.append(0)
            elif dx <= N+dt:
                v_rf.append(0)
                v_tr.append(0)
                v_dc.append(1)
            elif dx <= N+dt+M:
                v_rf.append(numpy.cos(2*numpy.pi*(dx-dt) + phi*numpy.pi/180))
                v_tr.append(0)
                v_dc.append(0)
            else:
                v_rf.append(0)
                v_tr.append(0)
                v_dc.append(0)
            v_dd.append(1)
            v_in.append(1)

    m1 = []; m2 = []; d1 = []; d2 = []; y = [];
    for i in range(0,len(v_in)):
        m1.append(v_in[i])
        m2.append(v_dd[i])
        d1.append(v_in[i])
        d2.append(v_tr[i])
        y.append(v_rf[i])

    return m1, m2, d1, d2, y

def make_ant_term_dc_source_short_gap_signal(M,N,os,phi,dt,mode):
    v_rf = [] # rf signal
    v_dd = [] # switch supply signal
    v_in = [] # switch control signal
    v_tr = [] # trigger signal
    v_dc = [] # antenna terminal dc source signal
    if mode=='decay':
        numpts = int(numpy.ceil(N+M+dt)*os)
        for i in range(numpts):
            dx = i/30.0
            if dx <= N:
                v_rf.append(numpy.cos(2*numpy.pi*dx + phi*numpy.pi/180))
                v_in.append(1)
                v_tr.append(1)
            elif dx <= N+dt:
                v_rf.append(0)
                v_in.append(0)
                v_tr.append(0)
            else:
                v_rf.append(0)
                v_in.append(1)
                v_tr.append(0)
            v_dd.append(1)
    elif mode=='driven':
        numpts = int(numpy.ceil(N+2*M+dt)*os)
        print(numpts)
        for i in range(numpts):
            dx = i/30.0
            if dx <= N:
                v_rf.append(numpy.cos(2*numpy.pi*dx + phi*numpy.pi/180))
                v_in.append(1)
                v_tr.append(0)
                v_dc.append(0)
            elif dx <= N+dt:
                v_rf.append(0)
                v_in.append(0)
                v_tr.append(0)
                v_dc.append(1)
            elif dx <= N+dt+M:
                v_rf.append(numpy.cos(2*numpy.pi*(dx-dt)+ phi*numpy.pi/180))
                v_in.append(1)
                v_tr.append(0)
                v_dc.append(0)
            else:
                v_rf.append(0)
                v_in.append(1)
                v_tr.append(0)
                v_dc.append(0)
            v_dd.append(1)

    elif mode=='conv':
        numpts = int(numpy.ceil(N+2*M+dt)*30)
        for i in range(numpts):
            dx = i/30.0
            if dx <= N:
                v_rf.append(numpy.cos(2*numpy.pi*dx + phi*numpy.pi/180))
                v_tr.append(1)
                v_dc.append(0)
            elif dx <= N+dt:
                v_rf.append(0)
                v_tr.append(0)
                v_dc.append(1)
            elif dx <= N+dt+M:
                v_rf.append(numpy.cos(2*numpy.pi*(dx-dt) + phi*numpy.pi/180))
                v_tr.append(0)
                v_dc.append(0)
            else:
                v_rf.append(0)
                v_tr.append(0)
                v_dc.append(0)
            v_dd.append(1)
            v_in.append(1)

    m1 = []; m2 = []; d1 = []; d2 = []; y1 = [];y2 = [];
    for i in range(0,len(v_in)):
        m1.append(v_in[i])
        m2.append(v_dd[i])
        d1.append(v_dc[i])
        d2.append(v_tr[i])
        y1.append(v_rf[i])
        y2.append(v_tr[i])
    print(len(d2))


    return m1, m2, d1, d2, y1, y2

def make_short_gap_signal(M,N,os,dt,mode):
    v_rf = [] # rf signal
    v_dd = [] # switch supply signal
    v_in = [] # switch control signal
    v_tr = [] # trigger signal
    if mode=='decay':
        numpts = int(numpy.ceil(N+M+dt)*30)
        for i in range(numpts):
            dx = i/30.0
            if dx <= N:
                v_rf.append(numpy.cos(2*numpy.pi*dx))
                v_in.append(1)
                v_tr.append(1)
            elif dx <= N+dt:
                v_rf.append(0)
                v_in.append(0)
                v_tr.append(0)
            else:
                v_rf.append(0)
                v_in.append(1)
                v_tr.append(0)
            v_dd.append(1)
    elif mode=='driven':
        numpts = int(numpy.ceil(N+2*M+dt)*30)
        for i in range(numpts):
            dx = i/30.0
            if dx <= N:
                v_rf.append(numpy.cos(2*numpy.pi*dx))
                v_in.append(1)
                v_tr.append(1)
            elif dx <= N+dt:
                v_rf.append(0)
                v_in.append(0)
                v_tr.append(0)
            elif dx <= N+dt+M:
                v_rf.append(numpy.cos(2*numpy.pi*(dx-dt)))
                v_in.append(1)
                v_tr.append(0)
            else:
                v_rf.append(0)
                v_in.append(1)
                v_tr.append(0)
            v_dd.append(1)

    m1 = []; m2 = []; d1 = []; d2 = []; y = [];
    for i in range(0,len(v_in)):
        m1.append(v_in[i])
        m2.append(v_dd[i])
        d1.append(v_in[i])
        d2.append(v_tr[i])
        y.append(v_rf[i])

    return m1, m2, d1, d2, y

def make_ook_bitseq(bitmode,numbits,startupbits):
    if bitmode=='prbs':
        random.seed(31090)
        bitseq = []
        for i in range(0,numbits):
            bitseq.append(random.randint(0,1));
    elif bitmode =='demo':
        if (numbits % 2 == 0):
            bitseq=[1,0]*int(numbits/4) +[1,1]*int(numbits/4)

    elif bitmode=='1010':
        if (numbits % 2 == 0):
            bitseq=[1,0]*int(numbits/2)
        else:
            raise RuntimeError('numbits must be even in 1010 bitmode')
    else:
        raise RuntimeError('possible bitmodes are ''1010'' and ''prbs'' and "demo"')
    return bitseq, startupbits

def make_ook_signal(method,N,fc,os,phi,bitseq, numbits,startupbits,marker_amplitude):
    # generate signal parameters and time series
    ################################
    samplespercycle = os
    samplespersymbol = samplespercycle*N
    symbolspersignal = 2*startupbits+numbits
    #symbolspersignal = startupbits+numbits
    samplespersignal = samplespersymbol*symbolspersignal
    x = range(0,samplespersignal)
    # put together bit sequence with startup, bits, and shutdown
    bits = [1]*startupbits + bitseq + [1]*startupbits
    bitseq2=[1,0]*int(numbits/2)
    bits2 = [1]*startupbits+bitseq2+[1]*startupbits
    # make rf mask to turn off rf signal during shutdown
    rfmask = [1]*startupbits + [1]*numbits + [0]*startupbits
    # construct logic signals for vdd, trigger, and switch control
    vdd = [];
    vin = [];
    vin2 = [];
    vtr = [];
    vrf = [];
    vdc = [];
    for i in range(symbolspersignal):
        vdd = vdd+[1]*samplespersymbol
        vin = vin+[bits[i]]*samplespersymbol;
        vin2 = vin2+[bits2[i]]*samplespersymbol;
        vdc = vdc+[-(bits[i]-1)]*samplespersymbol;
        if (i == 0):
            vtr = vtr+[1]*samplespersymbol
        else:
            vtr = vtr+[0]*samplespersymbol
        rfsymbol = [cos(2*pi*dx/os + phi*pi/180)*rfmask[i] for dx in range(0,samplespersymbol)]
        vrf = vrf+rfsymbol

    # setup data to sent to awg
    ################################
    # channel 1: m1 = vin, m2 = vdd
    # channel 2: d1 = data, d3 = trigger
    m1 = []; m2 = []; d1 = []; d2 = []; y = []; y2 = [];
    if method=='dam':
        for i in range(0,len(vin)):
            m1.append(vin[i])
            m2.append(vdd[i])
            d1.append(vin[i])
            #d1.append(vdc[i])
            d2.append(vtr[i])
            y.append(vrf[i]*vin[i]) # comment out vin2 to prevent pre-keyed carrier
            y2.append(vrf[i]*vin[i])# comment out vin1 to prevent-pre-keyed carrier
    elif method=='conv':
        for i in range(0,len(vin)):
            m1.append(1)
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i]*vin[i])
            y2.append(vtr[i])
    elif method=='cw':
        for i in range(0,len(vin)):
            m1.append(1)
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i])
            y2.append(vtr[i])
    else:
        raise RuntimeError('invalid method, options are ''dam'' or ''conv'' or ''cw''')
    return m1, m2, d1, d2, y, y2

def make_ook_signal_no_rf(method,N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude):
    # generate signal parameters and time series
    ################################
    samplespercycle = os
    samplespersymbol = samplespercycle*N
    symbolspersignal = 2*startupbits+numbits
    samplespersignal = samplespersymbol*symbolspersignal
    x = range(0,samplespersignal)
    # put together bit sequence with startup, bits, and shutdown
    bits = [1]*startupbits + bitseq + [0]*startupbits
    # make rf mask to turn off rf signal during shutdown
    rfmask = [1]*(30) + [0]*(startupbits-30) + [0]*numbits + [0]*startupbits
    # construct logic signals for vdd, trigger, and switch control
    vdd = [];
    vin = [];
    vtr = [];
    vrf = [];
    vdc = [];
    for i in range(symbolspersignal):
        vdd = vdd+[1]*samplespersymbol
        vin = vin+[bits[i]]*samplespersymbol;
        vdc = vdc+[-(bits[i]-1)]*samplespersymbol;
        if (i == 0): #trigger at the first symbol
            vtr = vtr+[1]*samplespersymbol
        else:
            vtr = vtr+[0]*samplespersymbol
        rfsymbol = [cos(2*pi*dx/os + phi*pi/180)*rfmask[i] for dx in range(0,samplespersymbol)]
        vrf = vrf+rfsymbol

    # setup data to sent to awg
    ################################
    # channel 1: m1 = vin, m2 = vdd
    # channel 2: d1 = data, d3 = trigger
    m1 = []; m2 = []; d1 = []; d2 = []; y = []; y2 = [];
    if method=='dam':
        for i in range(0,len(vin)):
            m1.append(vin[i])
            m2.append(vdd[i])
            d1.append(1)
            #d1.append(vdc[i])
            d2.append(vtr[i])
            y.append(vrf[i])
            y2.append(vrf[i])
    elif method=='conv':
        for i in range(0,len(vin)):
            m1.append(1)
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i]*vin[i])
            y2.append(vtr[i])
    elif method=='cw':
        for i in range(0,len(vin)):
            m1.append(1)
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i])
            y2.append(vtr[i])
    else:
        raise RuntimeError('invalid method, options are ''dam'' or ''conv'' or ''cw''')
    return m1, m2, d1, d2, y, y2

def make_mpsk_bitseq(M,bitmode,numbits,startupbits):
    bitseq = []
    if bitmode=='prbs':
        random.seed(31090)
        
        for i in range(0,numbits):
            bitseq.append(random.randint(0,M-1));
    elif bitmode=='1010':
        if (numbits % M == 0):
            bitseq = [range(0,M)]*int(numbits/M)
            #bitseq=(range(0,M)*int(numbits/M))
            startupbits = 0;
        else:
            raise RuntimeError('numbits must be multiple of M in 1010 bitmode')
    else:
        raise RuntimeError('possible bitmodes are ''1010'' and ''prbs''')

    return bitseq, startupbits

def make_mpsk_signal(M,method,N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude):
    # generate signal parameters and time series
    ################################
    samplespercycle = os
    samplespersymbol = samplespercycle*N
    symbolspersignal = 2*startupbits+numbits
    samplespersignal = samplespersymbol*symbolspersignal
    lprint('\tdata points to awg:'); print ('%0.0f' % samplespersignal)
    lprint('\tgenerating awg signals'); print ('')
    x = range(0,samplespersignal)

    # put together bit sequence with startup, bits, and shutdown
    bits = [0]*startupbits + bitseq + [0]*startupbits
    ps = [2*pi*float(bit)/float(M) for bit in bits];

    # make rf mask to turn off rf signal during shutdown
    rfmask = [1]*startupbits + [1]*numbits + [0]*startupbits

    # construct logic signals for vdd, trigger, and switch control
    vdd = [];
    vin = [];
    vtr = [];
    vrf = [];
    for i in range(symbolspersignal):
        # VDD
        vdd = vdd+[1]*samplespersymbol
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
        if i in range(1,len(ps)-1):
            if ps[i-1]!=ps[i]:
                for p in range(0,samplespersymbol):
                    if (float(p)/float(samplespercycle))<=(float(bits[i])/float(M)):
                        VC[p] = 0;
            if ps[i]!=ps[i+1]:
                for p in range(0,samplespersymbol):
                    if (float(samplespersymbol-p)/float(samplespercycle))<=(1-float(bits[i])/float(M)):
                        VC[p] = 0;
        vin = vin+VC

    # setup data to sent to awg
    ################################
    # channel 1: m1 = vin, m2 = vdd
    # channel 2: d1 = data, d3 = trigger
    m1 = []; m2 = []; d1 = []; d2 = []; y = [];
    if method=='dam':
        for i in range(0,len(vin)):
            m1.append(vin[i])
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i])
    elif method=='conv':
        for i in range(0,len(vin)):
            m1.append(1)
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i])
    else:
        raise RuntimeError('invalid method, options are ''dam'' or ''conv''')
    return m1, m2, d1, d2, y

def make_mpsk_signal_extralag(M,method,N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude):
    # generate signal parameters and time series
    ################################
    samplespercycle = os
    samplespersymbol = samplespercycle*N
    symbolspersignal = 2*startupbits+numbits
    samplespersignal = samplespersymbol*symbolspersignal
    lprint('\tdata points to awg:'); print ('%0.0f' % samplespersignal)
    lprint('\tgenerating awg signals'); print ('')
    x = range(0,samplespersignal)

    # put together bit sequence with startup, bits, and shutdown
    bits = [0]*startupbits + bitseq + [0]*startupbits
    ps = [2*pi*float(bit)/float(M) for bit in bits];

    # make rf mask to turn off rf signal during shutdown
    rfmask = [1]*startupbits + [1]*numbits + [0]*startupbits

    # construct logic signals for vdd, trigger, and switch control
    vdd = [];
    vin = [];
    vtr = [];
    vrf = [];
    for i in range(symbolspersignal):
        # VDD
        vdd = vdd+[1]*samplespersymbol
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
        if i in range(1,len(ps)-1):
            if ps[i-1]!=ps[i]:
                for p in range(0,samplespersymbol):
                    if (float(p)/float(samplespercycle))<=(1+float(bits[i])/float(M)):
                        VC[p] = 0;
            if ps[i]!=ps[i+1]:
                for p in range(0,samplespersymbol):
                    if (float(samplespersymbol-p)/float(samplespercycle))<=(1-float(bits[i])/float(M)):
                        VC[p] = 0;
        vin = vin+VC

    # setup data to sent to awg
    ################################
    # channel 1: m1 = vin, m2 = vdd
    # channel 2: d1 = data, d3 = trigger
    m1 = []; m2 = []; d1 = []; d2 = []; y = [];
    if method=='dam':
        for i in range(0,len(vin)):
            m1.append(vin[i])
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i])
    elif method=='conv':
        for i in range(0,len(vin)):
            m1.append(1)
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i])
    else:
        raise RuntimeError('invalid method, options are ''dam'' or ''conv''')
    return m1, m2, d1, d2, y

def make_chirp_signal_hmc194(numcycles,fbw,fc,os,marker_amplitude):
    # generate signal parameters and time series
    ################################
    cyclespersignal = numcycles
    samplespercycle = os
    samplespersignal = int(numcycles*os)
    dt = 1/(fc*os)
    tmax = (samplespersignal-1)*dt
    x = range(0,samplespersignal)

    # construct rf and logic signals for vdd, trigger, and switch control
    vdd = [0]*samplespersignal
    vin = [1]*samplespersignal
    vtr = [];
    vrf = [];
    for i in range(samplespersignal):
        vrf.append(cos(2*pi*dt*i*(fc*(1-fbw/2)+dt*i/tmax*fc*fbw/2)))
        if (dt*i<=tmax*0.02) and (dt*i>=tmax*0):
            vtr.append(1)
        else:
            vtr.append(0)


    # setup data to sent to awg
    ################################
    # channel 1: m1 = vin, m2 = vdd
    # channel 2: d1 = data, d3 = trigger
    m1 = []; m2 = []; d1 = []; d2 = []; y1 = []; y2 = [];
    for i in range(0,len(vin)):
        m1.append(1)
        m2.append(vdd[i])
        d1.append(vin[i])
        d2.append(vtr[i])
        y1.append(vrf[i])
        y2.append(vtr[i])
    return m1, m2, d1, d2, y1, y2

def make_chirp_signal(numcycles,fbw,fc,os,marker_amplitude):
    # generate signal parameters and time series
    ################################
    cyclespersignal = numcycles
    samplespercycle = os
    samplespersignal = int(numcycles*os)
    dt = 1/(fc*os)
    tmax = (samplespersignal-1)*dt
    x = range(0,samplespersignal)

    # construct rf and logic signals for vdd, trigger, and switch control
    vdd = [1]*samplespersignal
    vin = [1]*samplespersignal
    vtr = [];
    vrf = [];
    for i in range(samplespersignal):
        vrf.append(cos(2*pi*dt*i*(fc*(1-fbw/2)+dt*i/tmax*fc*fbw/2)))
        if (dt*i<=tmax*0.02) and (dt*i>=tmax*0):
            vtr.append(1)
        else:
            vtr.append(0)


    # setup data to sent to awg
    ################################
    # channel 1: m1 = vin, m2 = vdd
    # channel 2: d1 = data, d3 = trigger
    m1 = []; m2 = []; d1 = []; d2 = []; y1 = []; y2 = [];
    for i in range(0,len(vin)):
        m1.append(1)
        m2.append(vdd[i])
        d1.append(vin[i])
        d2.append(vtr[i])
        y1.append(vrf[i])
        y2.append(vtr[i])
    return m1, m2, d1, d2, y1, y2

def tile_and_stack(repeatlength,sigs_a,sigs_b):
        # repeat for burst averaging
        ################################
        m1 = numpy.concatenate((numpy.tile(sigs_a[0], repeatlength),numpy.tile(sigs_b[0], repeatlength)))
        m2 = numpy.concatenate((numpy.tile(sigs_a[1], repeatlength),numpy.tile(sigs_b[1], repeatlength)))
        d1 = numpy.concatenate((numpy.tile(sigs_a[2], repeatlength),numpy.tile(sigs_b[2], repeatlength)))
        if repeatlength > 1:
            d2 = numpy.concatenate((numpy.tile(sigs_a[3], 1),numpy.tile(sigs_b[3], 2*repeatlength-1)))
        else:
            d2 = numpy.concatenate((numpy.tile(sigs_a[3], repeatlength),numpy.tile(sigs_b[3], repeatlength)))
        y1 = numpy.concatenate((numpy.tile(sigs_a[4], repeatlength),numpy.tile(sigs_b[4], repeatlength)))
        y2 = numpy.concatenate((numpy.tile(sigs_a[5], repeatlength),numpy.tile(sigs_b[5], repeatlength)))
        return m1, m2, d1, d2, y1, y2

def make_2fsk_bitseq(bitmode,numbits,startupbits):
    return make_ook_bitseq(bitmode,numbits,startupbits)

def make_2fsk_signal(method,fc1,fc2,N1,os,tau,phi1,phi2,bitseq,numbits,startupbits,marker_amplitude):
    # notes
    ################################
    # symbol length = N1 / fc1
    # phi1 and phi2 are the relative phases of each carrier within each symbol
    # switching at peaks: phi1 = phi2 = 0
    # switching at zeros: phi1 = phi2 = 90
    # tau is an offset time to synchronize the switching control with the carrier, needs to be experimentally determined
    # os is an oversampling rate, based on fc1

    # check that data rate and frequencies satisfy integer cycles / symbol condition
    ################################
    N2 = fc2/fc1*N1
    if (N2 % 1)>1e-6:
        raise RuntimeError('supplied carrier frequencies and data rate are not integer compatible')
    df = fc2/fc1

    # generate signal parameters and time series
    ################################
    samplespercycle = os
    samplespersymbol = samplespercycle*N1
    symbolspersignal = 2*startupbits+numbits
    samplespersignal = samplespersymbol*symbolspersignal
    x = range(0,samplespersignal)
    # put together bit sequence with startup, bits, and shutdown
    bits = [1]*startupbits + bitseq + [0]*startupbits
    # make rf mask to select frequency in each symbol
    rfmask = [1]*startupbits + [1]*numbits + [0]*startupbits
    # construct logic signals for vdd, trigger, and switch control
    vdd = [];
    vin = [];
    vtr = [];
    vrf = [];
    for i in range(symbolspersignal):
        vdd = vdd+[1]*samplespersymbol
        vin = vin+[bits[i]]*samplespersymbol;
        if (i == 0):
            vtr = vtr+[1]*samplespersymbol
        else:
            vtr = vtr+[0]*samplespersymbol
        if bits[i]==1:
            rfsymbol = [cos(2*pi*dx/os + phi1*pi/180)*rfmask[i] for dx in range(0,samplespersymbol)]
        else:
            rfsymbol = [cos(2*pi*dx/os*df + phi2*pi/180)*rfmask[i] for dx in range(0,samplespersymbol)]
        vrf = vrf+rfsymbol

    # setup data to sent to awg
    ################################
    # channel 1: m1 = vin, m2 = vdd
    # channel 2: d1 = data, d3 = trigger
    m1 = []; m2 = []; d1 = []; d2 = []; y = [];
    if method=='dam':
        for i in range(0,len(vin)):
            m1.append(vin[i])
            m2.append(vdd[i])
            d1.append(vin[i])
            d2.append(vtr[i])
            y.append(vrf[i])
    elif method=='conv-state1':
        for i in range(0,len(vin)):
            m1.append(1)
            m2.append(vdd[i])
            d1.append(1)
            d2.append(vtr[i])
            y.append(vrf[i])
    elif method=='conv-state0':
        for i in range(0,len(vin)):
            m1.append(0)
            m2.append(vdd[i])
            d1.append(0)
            d2.append(vtr[i])
            y.append(vrf[i])
    else:
        raise RuntimeError('invalid method, options are ''dam'' or ''conv-state1'' or ''conv-state0''')

    # roll m1 for tau delay
    Ndel = int(numpy.floor(os*tau*fc1))
    m1 = numpy.roll(m1,Ndel)
    return m1, m2, d1, d2, y

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
    os = 30;                 # awg oversampling rate
    repeatlength = 5;       # number of times to repeat sequence
    marker_amplitude = 1;

    ## set ook properties
    #########################################
    method = 'conv';          # modulation method ('cw', 'dam', or 'conv')
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
    bitseq, startupbits = make_ook_bitseq(bitmode,numbits,startupbits)

    ## make signals
    #########################################
    sigs_ook = make_ook_signal(N,fc,os,phi,bitseq,numbits,startupbits,marker_amplitude)
    plt.figure()
    plt.subplot(211)
    plt.plot(sigs_ook[3])

    sigs_chirp = make_chirp_signal(numcycles,fbw,fc,os,marker_amplitude)
    plt.subplot(211)
    plt.plot(sigs_chirp[3])

    sigs_total = tile_and_stack(repeatlength,sigs_chirp,sigs_ook)
    plt.subplot(212)
    plt.plot(sigs_total[3])
    plt.show()
