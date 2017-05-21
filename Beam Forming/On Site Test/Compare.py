import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np


raw = pd.read_csv('original.csv', header = None)
target = pd.read_csv('target.csv', header = None)
Freraw = np.abs(np.fft.rfft(raw.ix[:,0], 30000))
Freraw = Freraw[:-10] + Freraw[1:-9] + Freraw[2:-8] + Freraw[3:-7] + Freraw[4:-6] + Freraw[5:-5] + Freraw[6:-4] + Freraw[7:-3]
Freraw /= 8
Frebeam = np.abs(np.fft.rfft(target.ix[:,0], 30000))
Frebeam = Frebeam[:-10] + Frebeam[1:-9] + Frebeam[2:-8] + Frebeam[3:-7] + Frebeam[4:-6] + Frebeam[5:-5] + Frebeam[6:-4] + Frebeam[7:-3]
Frebeam /= 8
plt.figure(figsize = (12,9))
sns.set(font_scale=1.5)
sns.set_style('white')
with sns.color_palette("Blues", 1):
    plt.plot(np.linspace(0,1,len(raw)),raw.ix[:,0],label = 'Beamforming Signal')
    #plt.plot(20*np.log10(Freraw),label = 'Normal Microphone Signal')
plt.plot(np.linspace(0,1,len(raw)),target.ix[:,0], label = 'Normal Microphone Signal',c = 'k')
#plt.plot(20*np.log10(Frebeam), label = 'Beamforming Signal', c = 'k')

#plt.plot([1100,1300],[51,51], 'k', linewidth = 3)
#plt.plot([1100,1300],[31,31], 'k', linewidth = 3)
#plt.text(1250,40, '20 dB Reduction')
#plt.xlim([0,2000])
#plt.ylim([-20,80])
#plt.xlabel('Frequency (Hz)')
#plt.ylabel('dB')
plt.xlim([0,0.05])
plt.ylim([-.3,.4])
plt.legend(fontsize = 18)
plt.savefig('beamPerformance',dpi = 600)
plt.show()