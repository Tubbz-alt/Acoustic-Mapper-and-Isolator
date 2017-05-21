# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a simulation of plane wave beamforming.
"""
from __future__ import division
import numpy as np
import matplotlib.pyplot as plt
import math

N_beam = 8
spacing = 0.2
c = 340

fre_1 = 750
inci_1 = 50  # degree
mag_1 = 50
phi_1 = 0
delta_t_1 = spacing*math.cos(inci_1/180*math.pi)/c

fre_2 = 700
inci_2 = 80 # degree
mag_2 = 50
phi_2 = 0
delta_t_2 = spacing*math.cos(inci_2/180*math.pi)/c

fre_3 = 800
inci_3 = 110
mag_3 = 50
phi_3=0
delta_t_3 = spacing*math.cos(inci_3/180*math.pi)/c

fre_4 = 900
inci_4 = 140
mag_4 = 50
phi_4=0
delta_t_4 = spacing*math.cos(inci_4/180*math.pi)/c

fs = 30000
N = 30000
f_max = 1500
t = np.arange(0,N/fs,1/fs)
f = np.arange(0,f_max,fs/N)

## Generating received signal for microphone array
A_original = np.zeros((N,N_beam))
A_original_f = np.zeros((N,N_beam))
for i in range(1,N_beam+1):
    
    t_temp_1 = t+delta_t_1*(i-1)
    t_temp_2 = t+delta_t_2*(i-1)
    t_temp_3 = t+delta_t_3*(i-1)
    t_temp_4 = t+delta_t_4*(i-1)
    
    A_original[:,i-1] = mag_1*np.sin(2*math.pi*fre_1*t_temp_1+phi_1)+mag_2*np.sin(2*math.pi*fre_2*t_temp_2+phi_2)+mag_3*np.sin(2*math.pi*fre_3*t_temp_3+phi_3)+mag_4*np.sin(2*math.pi*fre_4*t_temp_4+phi_4)
    A_original_f[:,i-1] = abs(np.fft.fft(A_original[:,i-1],N))*2/fs

plt.figure(1)
plt.plot(f,A_original_f[0:len(f),0])
plt.show()

## beamforing analysis
def plane_beamforming(incident_angle, A_original):
    'Performing the plane_beamforming algorithm, incident_angle in degree between incident plane wave and microphone array line'

    delta_t = spacing*math.cos(incident_angle/180*math.pi)/c
    delta_point = int(delta_t*fs)
    Num_max = abs(delta_point)*(N_beam-1)

    A_temp = np.zeros((N+Num_max,N_beam))
    A_filter = np.zeros((N,N_beam))
    result = np.zeros(N-Num_max)

    if delta_point > 0:
        for i in range(1,N_beam+1):
    
            A_temp[0:N+(i-1)*delta_point,i-1] = np.append(np.zeros(((i-1)*delta_point,1)),A_original[:,i-1])
            A_filter[:,i-1] = A_temp[0:N,i-1]
            result = result+A_filter[Num_max:,i-1]

    elif delta_point <= 0:
        for i in range(1,N_beam+1):
    
            A_temp[0:N+abs((N_beam-i)*delta_point),i-1] = np.append(np.zeros(((N_beam-i)*abs(delta_point),1)), A_original[:,i-1])
            A_filter[:,i-1] = A_temp[0:N,i-1]
            result = result+A_filter[Num_max:,i-1]
    return result

power_ = np.zeros(37)
for j in range(0,37):
    
    incident_angle = j*5
    result = plane_beamforming(incident_angle,A_original)
    N_ = len(result)
    result_f = abs(np.fft.fft(result,N_))*2/fs
    power_[j] = 10*math.log(math.sqrt(sum(result_f*result_f)))
    
plt.figure(2)
plt.plot(np.arange(0,37)*5,power_)
plt.show()

incident_angle_1 = 50
result_1 = plane_beamforming(incident_angle_1,A_original)
N_1 = len(result_1)
f_1 = np.arange(0,f_max,fs/N_1)
result_f_1 = abs(np.fft.fft(result_1,N_1))*2/fs
                
plt.figure(3)
plt.plot(f_1,result_f_1[0:len(f_1)])
plt.show()

incident_angle_2 = 80
result_2 = plane_beamforming(incident_angle_2,A_original)
N_2 = len(result_2)
f_2 = np.arange(0,f_max,fs/N_2)
result_f_2 = abs(np.fft.fft(result_2,N_2))*2/fs
                
plt.figure(4)
plt.plot(f_2,result_f_2[0:len(f_2)])
plt.show()

incident_angle_3 = 110
result_3 = plane_beamforming(incident_angle_3,A_original)
N_3 = len(result_3)
f_3 = np.arange(0,f_max,fs/N_3)
result_f_3 = abs(np.fft.fft(result_3,N_3))*2/fs
                
plt.figure(5)
plt.plot(f_3,result_f_3[0:len(f_3)])
plt.show()

incident_angle_4 = 140
result_4 = plane_beamforming(incident_angle_4,A_original)
N_4 = len(result_4)
f_4 = np.arange(0,f_max,fs/N_4)
result_f_4 = abs(np.fft.fft(result_4,N_4))*2/fs
                
plt.figure(6)
plt.plot(f_4,result_f_4[0:len(f_4)])
plt.show()