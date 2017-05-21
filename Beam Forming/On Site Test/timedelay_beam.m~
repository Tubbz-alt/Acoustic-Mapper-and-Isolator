clear
clc

sensi = [0.455,0.453,0.482,0.476,0.451,0.473,0.502,0.468]; % V / Pa

%% Read in the original signal

filename = '3.dat';
fs = 30100; %sampling frequency
N = 30100;
channel = 8;
fid = fopen(filename,'rb');
tim = 4;
if (fid>=0)
    fseek(fid,16,'bof'); % 34 is the header bytes, it is a random number from 0 to 34
    %     for iii=1:10000
    AA=fread(fid,tim*channel*fs,'uint16');
    AA=(AA-32767)*10/32767;
        
    for i=1:8
        
        AAA=AA(i:channel:end);
        AAA = AAA-mean(AAA);
        dataname = strcat('A',num2str(i));
        assignin('base',dataname,AAA);
     end
end

start_p = 20000;
end_p = start_p+N-1;
A_original = [A1(start_p:end_p) A2(start_p:end_p) A3(start_p:end_p) A4(start_p:end_p)...
              A5(start_p:end_p) A6(start_p:end_p) A7(start_p:end_p) A8(start_p:end_p)];
A_original_f = abs(fft(A_original,N))*2/fs;

fclose(fid);

%% obtain the extracted signal based on the input angle

%Apply Frost Beamforming to ULA

rng default
%ha = phased.ULA('NumElements',3,'ElementSpacing',0.31);
ha = phased.ULA('NumElements',8,'ElementSpacing',0.2);
ha.Element.FrequencyRange = [20 2000];
t = (0:1/fs:1-1/fs).';
c = 340;

rx = A_original;
for i = 1:91
    angle = (i-1)*2-90;
    incidentAngle = [angle;0];
    %%
    % Beamforming the signal.
    
    hbf = phased.TimeDelayBeamformer('SensorArray',ha,...
        'PropagationSpeed',c,'SampleRate',fs,...
        'Direction',incidentAngle);
    y(:,i) = step(hbf,rx);
    power(1,i) = sqrt(sum(y(:,i).^2));
    
end

%%
% Plot the beamformed output.
figure(1)
plot(t,rx(1:length(t),1));

figure(2)
f = 0:fs/N:1500-fs/N;
rx_f = abs(fft(rx(:,2),N))*2/fs;
plot(f,rx_f(1:length(f)));
xlabel('Frequency')
ylabel('Amplitude')

figure(3)
plot(((1:91)-1)*2-90,10*log10(power))

threshold = (max(power)+min(power))/2;


incident_angle_1 = -14;
index_1 = (incident_angle_1+90)/2+1;
result_1 = y(:,index_1);
N_1 = length(result_1);
f_1 = 0:fs/N_1:1500-fs/N_1;
result_f_1 = abs(fft(result_1(1:N_1,1,1),N_1))*2/fs;

figure(4)
%plot(f_1,20*log10(result_f_1(1:length(f_1))))
plot(f_1,result_f_1(1:length(f_1)))

incident_angle_2 = 14;
index_2 = (incident_angle_2+90)/2+1;
result_2 = y(:,index_2);
N_2 = length(result_2);
f_2 = 0:fs/N_2:1500-fs/N_2;
result_f_2 = abs(fft(result_2(1:N_2,1,1),N_2))*2/fs;

figure(5)
%plot(f_2,20*log10(result_f_2(1:length(f_2))))
plot(f_2,result_f_2(1:length(f_2)))

figure(6)
plot(t,rx(1:length(t),1),'r:',t,result_2(1:length(t)));
