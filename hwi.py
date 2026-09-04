'''
hwi.py
Kurt Schab
NCSU
---------------------------------------
a module for connecting to and communicating with lab
equipment over tcpip.  organized as follows:

I.  	setup commands for this library
II. 	display utilities
III. 	addresses of equipment
IV. 	interface methods
V. 		connection functions
VI. 	data parsing functions
VII. 	library test routine (only runs when called as a program)
'''

# I. SETUP
################################################################
import pyvisa as visa
import time
from math import *
import matplotlib.pyplot as plt
from types import MethodType
rm = visa.ResourceManager()

# II. DISPLAY UTILITIES
################################################################
def lprint(str):
	print("{0:<30}".format(str)),

def rprint(str):
	print("{0:<19}".format(str[0:19]))

def lineprint():
	print("{0:=>50}".format(""))

# III. ADDRESSES
################################################################
def address_e5071c():
	return 'TCPIP::192.168.1.111::INSTR'

def address_awg70002a():
	return 'TCPIP0::192.168.1.107::inst0::INSTR'

def address_dpo70404c():
	return 'TCPIP0::192.168.1.108::inst0::INSTR'

# IV. INTERFACE METHODS
################################################################
def fetch_data_dpo70404c(self, ch, numpts,debugoutput=0):
	if ch in [1,2,3,4]:
		self.write('DATA:SOURCE CH%d' % ch )
	else:
		raise RuntimeError("ch must be 1-4")
	self.write('DATA:ENCDG RPB')
	self.write('WFMOutpre:BYT_Nr 2')
	self.write('DATA:START 1')
	self.write('DATA:STOP %d' % numpts)
	preamble = self.query('WFMOUTPRE?')
	time.sleep(0.5)
	data = self.query_binary_values('CURVE?',datatype='H',is_big_endian=True)
	if debugoutput:
		print(preamble)
		print(len(data))
		plt.plot(data)
		plt.show()
	return preamble, data

def send_data_awg70002a(self, channel, signal, marker1, marker2, adcres=8):
	samplespersignal = len(signal)
	if not ((len(marker1)==len(marker2)) & (len(marker1)==len(signal))):
		raise RuntimeError("signal and marker data vectors mut be the same length")
	marker = []
	for i in range(0,len(marker1)):
		marker.append(marker1[i]*64 + marker2[i]*128)
	#comment out the next three lines to avoid error on awg when running tests
	self.write('WLIST:WAVEFORM:NEW "WFM%d", %d' % (channel,samplespersignal))
	self.write_binary_values('WLIST:WAVEFORM:DATA "WFM%d",0,%d,' % (channel,samplespersignal), signal);
	self.write_binary_values('WLIST:WAVEFORM:MARKER:DATA "WFM%d",0,%d,' % (channel,samplespersignal), marker, datatype='B');

    #a = self.query_binary_values('WLIST:WAVEFORM:MARKER:DATA?');
	#print(a)
	self.write('SOURCE%d:DAC:RESOLUTION %d' % (channel, adcres))
	#b=self.query('SOURCE%d:DAC:RESOLUTION?')
	#print(b)
	self.write('SOURCE%d:CASSET:WAVEFORM "WFM%d"' % (channel, channel))
	#self.write('SOURCE1:CASSET:WAVEFORM "WFM1"' % (channel, channel))
	time.sleep(2)
    


def enable_channel_awg70002a(self, channel, amplitude=0.5):
	self.write('SOURCE%d:VOLTAGE:AMPLITUDE %0.2f' % (channel, amplitude))
	self.query('SOURCE:VOLTAGE:AMPLITUDE?')
	self.write('OUTPUT%d:STATE ON' % channel)

def toggle_output_awg70002a(self,state):
	if state=='on':
		self.write('AWGCONTROL:RUN')
	if state=='off':
		self.write('AWGCONTROL:STOP')
	#raise RuntimeError("state must be 'on' or 'off'")

def check_awg_rate(fc,os):
    # calculate clock rate, check if below AWG spec
    fs = fc*os;
    if (fs > 8e9):
      raise RuntimeError('calculated clock rate > 8 GHz, lower carrier frequency or oversampling rate.')
    return fs

# V. CONNECTION FUNCTIONS
################################################################
def connect_to_awg70002a(reset=0,showid=0):
	awg = rm.open_resource(address_awg70002a());
	if showid:
		print(awg.query('*IDN?')[0:19])
	if reset:
		awg.write('*RST')
		time.sleep(3)
	awg.timeout = 30000
	awg.send_data = MethodType(send_data_awg70002a, awg)
	awg.enable_channel = MethodType(enable_channel_awg70002a, awg)
	awg.toggle_output = MethodType(toggle_output_awg70002a,awg)
	return awg

def connect_to_dpo70404c(reset=0,showid=0):
	dpo = rm.open_resource(address_dpo70404c());
	if showid:
		print(dpo.query('*IDN?')[0:19])
	if reset:
		dpo.write('*RST')
	dpo.timeout = 30000
	dpo.fetch_data = MethodType(fetch_data_dpo70404c, dpo)
	return dpo

def connect_to_e5071c(reset=0,showid=0):
	vna = rm.open_resource(address_e5071c());
	if showid:
		print(vna.query('*IDN?')[0:19])
	if reset:
		vna.write('*RST')
	return vna

# VI. DATA PARSING FUNCTIONS
################################################################
def parse_data_dpo70404c(preamble, data):
	predata = preamble.split(';');
	a = predata[9].split()
	dt = float(a[0]);
	b = predata[13].split()
	dy = float(b[0]);
	#dy = float(predata[13]);
	c = predata[14].split()
	y0 = float(c[0]);
	#y0 = float(predata[14])
	N = len(data);
	x = [dt*m for m in range(0,N)]
	y = [dy*(m-y0) for m in data]
	return x, y

# VII. MODULE TESTING PROGRAM
# (only runs when this file is executed as a script)
################################################################
if __name__ == '__main__':
	print('')
	print('hwi.py')
	print('running module tests')
	lineprint()

	lprint('connecting to awg70002a... '),
	try:
		awg = connect_to_awg70002a(reset=0,showid=0)
		rprint(awg.query('*IDN?'))
	except:
		rprint('failed.')

	lprint('connecting to dpo70404c... '),
	try:
		dpo = connect_to_dpo70404c(reset=0,showid=0)
		rprint(dpo.query('*IDN?'))
	except:
		rprint('failed.')

	lprint('connecting to e5071c... '),
	try:
		vna = connect_to_e5071c(reset=0,showid=0)
		rprint(vna.query('*IDN?'))
	except:
		rprint('failed.')

	lprint('sending data to awg...')
	try:
		N = 5;                   # number of cycles / symbol
		fc = 30e6;               # carrier frequency
		os = 30;                 # oversampling rate
		samplespercycle = os
		samplespersymbol = samplespercycle*N
		symbolspersignal = 1
		samplespersignal = samplespersymbol*symbolspersignal
		dx = range(0,samplespersignal)
		signal = [cos(2*pi*ddx/os) for ddx in dx]
		marker1 = [s*0+1 for s in signal]
		marker2 = [s*0+1 for s in signal]
		#wfm = awg.query('wlist:name? 1')
		#print(wfm)
		#awg.write('source:casset:waveform',wfm)
		awg.send_data(channel=1,signal=signal,marker1=marker1,marker2=marker2)
		rprint('success.')
	except:
		rprint('failed.')

	lprint('enabling awg channel 1...')
	try:
		awg.enable_channel(1)
		rprint('success.')
	except:
		rprint('failed.')

	lprint('running awg...')
	try:
		awg.toggle_output('on')
		time.sleep(4)
		rprint('success.')
	except:
		rprint('failed.')

	lprint('polling dpo ch1...'),
	try:
		preamble, data = dpo.fetch_data(1,10000,debugoutput=0)
		x, y = parse_data_dpo70404c(preamble, data)
		plt.plot(x,y)
		plt.show()
		rprint('success.')
	except:
		rprint('failed.')

	lprint('turning off awg...')
	try:
		awg.toggle_output('off')
		rprint('success.')
	except:
		rprint('failed.')
