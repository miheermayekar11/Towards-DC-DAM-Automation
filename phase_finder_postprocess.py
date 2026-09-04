from postprocessing import *
from time import *
import numpy
import matplotlib
from datetime import datetime
matplotlib.rcParams['font.family'] = 'serif'
matplotlib.rcParams['font.serif'] = 'CMU Serif, Times New Roman'
plt.rcParams['mathtext.fontset'] = 'cm'
from matplotlib import gridspec
plt.ion()

##########################################################

def make_fft(t,y):
    dt = t[1]-t[0]
    L = len(t)
    samplerate = 1/dt
    f = np.fft.fftfreq(L, d=1./samplerate)
    Y = np.fft.fft(y)
    return f, Y

##########################################################
# main program
##########################################################
today = datetime.now()
savedir_date = today.strftime('%Y%m%d')
savedir_loc = 'C:/Users/mpmayeka/Desktop/DATA/';#'D:/DATA/'; #External Drive in this case its COOPER
savedir = savedir_loc+savedir_date+'/phase finder/'


dir = 'C:/Users/mpmayeka/Desktop/DATA/20250104/phase finder/' #'D:/DATA/20230927/phase finder/'
alpha = 0.4
dt = 20
dphi1 = []
val = []
PHI = numpy.arange(0,360,10);
PHI2 = numpy.arange(0,360,10);
for phi in PHI:
	#query = "20dB_nearfield_oc_dam_driven_dam_fc_2.600000e+07_N_start_50_N_cooldown_50_dc_1.2_phi_%s_phi2_%s_dt_20" %(phi,phi)
	query = "20250104-130113_dpo_testing_phase_finder_1010_dam_fc_2.691000e+07_N_start_50_N_cooldown_50_dc_0.0_phi_%s_phi2_%s_dt_20" %(phi,phi) #"20230927-134230_dpo_testing_phase_finder_1010_dam_fc_1.000000e+07_N_start_10_N_cooldown_50_dc_0.5_phi_%s_phi2_%s_dt_20" %(phi,phi)
	rx_filelist = iget_filenames_dpo_auto(dir,query)
	print("\n")
	print("TX S11 data... (enter in array form, e.g., [0])")
	#tx_s11_fid = iget_filenames(dir,"TX") #Uncomment to use Tx transfer fucntion
	tx_s11_fid = [0]
	print("\n")
	print("RX S11 data...(enter in array form, e.g., [0])")
	#rx_s11_fid = iget_filenames(dir,"RX") #uncomment to use RX transfer function
	rx_s11_fid = [0]
	for rx_filename in rx_filelist:
		tx_filename = rx_filename.replace("dpo","awg")

		# pull in rx data
		rx_data = load_data(rx_filename)
		threshold = 0.5
		toff = find_toff(rx_data,threshold)
		t1 = rx_data["t"]
		b1 = (t1 >= toff)
		t1_ = t1[b1]-toff
		y1_ = rx_data["y"][b1]

		t0 = 50/rx_data["fc"]

		# plot rx signal
		plt.figure(112)
		plt.subplot(211)
		plt.plot(t1_-dt/rx_data["fc"]-t0,y1_,alpha=alpha)
		plt.ylabel(r'$V_\mathrm{rx}$')
		plt.xlim([-10e-7,6e-7])
		plt.title(r'$\mathrm{ADG}919, \mathrm{dam}, 13\mathrm{dB}, N = 5$')

		# plot spectrum and apply brick wall BPF
		f, y = make_fft(t1_,y1_)
		b = (numpy.abs(f)>rx_data["fc"]*1.3)
		#plot spetrum
		plt.figure(888)
		plt.loglog(f,abs(y))
		y[b]=0
		b = (numpy.abs(f)<rx_data["fc"]*0.7)
		y[b]=0
		#plot spectrum after filtering
		plt.figure(890)
		plt.loglog(f,abs(y))
		y = numpy.fft.ifft(y)

		#find the optimal phase theta = rx_data["phi"] + dphi (find out what phase gives us the highest I channel steady state)
		iq_diff = []
		yi_ = []
		yq_ = []
		dPHI = np.arange(-180,180,5)
		for dphi in dPHI:
			#demodulation
			#I channel
			i_ = y*numpy.cos(2*numpy.pi*rx_data["fc"]*(t1_-dt/rx_data["fc"]-t0)-pi/180.0*(rx_data["phi"] + dphi))
			f, I_ = make_fft(t1_,i_)
			b = (numpy.abs(f)>rx_data["fc"]*0.3)
			I_[b]=0
#			I_ = I_[numpy.abs(f)>rx_data["fc"]*0.5]
			i_ = np.real(np.fft.ifft(I_))
			#Q channel
			q_ = y*numpy.sin(2*numpy.pi*rx_data["fc"]*(t1_-dt/rx_data["fc"]-t0)-pi/180.0*(rx_data["phi"] + dphi))
			f, Q_ = make_fft(t1_,q_)
			b = (numpy.abs(f)>rx_data["fc"]*0.3)
			Q_[b] = 0
#			Q_ = Q_[numpy.abs(f)>rx_data["fc"]*0.5]
			q_ = np.real(np.fft.ifft(Q_[b]))
			#locate the steady state:
			t_shift = t1_-t0+5/rx_data["fc"]
			b = (abs(t_shift+0/rx_data["fc"])<2/rx_data["fc"])
			yi_.append(numpy.mean(i_[b]))
#			yi_.append(numpy.mean(i_))

		#find the highest steady state case
		m = max(yi_)
		#n = min(yi_)
		index = yi_.index(m)
		print(yi_[index])
		#print(iq_diff[index])
		a = dPHI[index]
		theta =  a + rx_data["phi"]

		#demodulation (LPF applied)
		#I channel
		I = y*numpy.cos(2*numpy.pi*rx_data["fc"]*(t1_-dt/rx_data["fc"]-t0)-pi/180.0*(theta))
		f, i = make_fft(t1_,I)
		b = (numpy.abs(f)>rx_data["fc"]*0.3)
		i[b]=0
#		i = i[numpy.abs(f)>rx_data["fc"]*0.3]
		I_filt = numpy.fft.ifft(i)

		#nomalize the I channel demodulated signal by its steady state
		t0 = 50/rx_data["fc"]
		t_shift = t1_-t0+5/rx_data["fc"]
		b = (abs(t_shift+0/rx_data["fc"])<2/rx_data["fc"])
#		I_filt = I_filt[abs(t_shift+0/rx_data["fc"])<2/rx_data["fc"]]
		I_ss = max(I_filt[b[0:len(I_filt)]])
#		I_ss = max(I_filt)
		I_filt = I_filt/I_ss
		#plot I channel demodulated signal
		plt.figure(112)
		plt.subplot(212)
		plt.plot(t1_[0:len(I_filt)]-dt/rx_data["fc"]-t0,I_filt,alpha=alpha)
		plt.xlabel(r'$t,\/\mathrm{s}$')
		plt.ylabel(r'$y_\mathrm{i}$')
		plt.xlim([-10e-7,6e-7])
		#locate the "gray area" for Envelope Retention and find the mean value of the area
		t_shift = t1_-dt/rx_data["fc"]-t0
		b = (abs(t_shift-3/rx_data["fc"])<1.5/rx_data["fc"])
		#collect the data for each phase
		val.append(numpy.mean(I_filt[b[0:len(I_filt)]]))
		dphi1.append(phi)

#plot "gray area"
plt.fill([1.5/rx_data["fc"],1.5/rx_data["fc"],4.5/rx_data["fc"],4.5/rx_data["fc"]],[-0.1,1,1,-0.1],'black',alpha=0.3)

val = numpy.array(val)
dphi1 = numpy.array(dphi1)
max_val = max((val))
index_phase = numpy.where(val == max_val)
print('the phase location is \n',index_phase)
phase_best = dphi1[index_phase]
print('the optimal phase is:\n', phase_best)


# figure of ER vs phase
plt.figure(229)
plt.plot(dphi1,(val))
plt.xlabel(r'$\phi$')
plt.ylabel('ER')
plt.title(r'$\mathrm{ADG}919, \mathrm{dam}')
plt.grid()

plt.ioff()
plt.show()

# done flag

print("done.")
