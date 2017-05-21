clear
clc

N_beam = 8;
spacing = 0.2;
c = 340;

fs = 30100;
N = 30100;
t = 0:1/fs:(N-1)/fs;

%% Generating received signal for microphone array
% A_original = zeros(N,N_beam);
% A_original_f = zeros(N,N_beam);
% for i = 1:N_beam
%     
%     t_temp_1 = t+delta_t_1*(i-1);
%     t_temp_2 = t+delta_t_2*(i-1);
%     A_original(:,i) = mag_1*sin(2*pi*fre_1*t_temp_1+phi_1)+mag_2*sin(2*pi*fre_2*t_temp_2+phi_2);
%     A_original_f(:,i) = abs(fft(A_original(:,i),N))*2/fs;
% 
% end

sensi = [0.455,0.453,0.482,0.476,0.451,0.473,0.502,0.468]; % V / Pa

filename = '3.dat';

%fs = 10000;
fs = 30100; %sampling frequency
channel = 8;
fid = fopen(filename,'rb');
tim = 4;
if (fid >= 0)
    fseek(fid,16,'bof'); % 34 is the header bytes, it is a random number from 0 to 34
    %     for iii=1:10000
    AA = fread(fid,tim*channel*fs,'uint16');
    AA = (AA-32767)*10/32767;
        
    for i = 1:8
        %1-8 vibration 9-11 current 12-13 nutral cureent 14-16 voltage 17 tem
        AAA = AA(i:channel:end)/sensi(1,i);
        AAA = AAA-mean(AAA);
        dataname = strcat('A',num2str(i));
        assignin('base',dataname,AAA);
     end
end

fclose(fid);

start_p = 20000;
end_p = start_p+N-1;
A_original = [A1(start_p:end_p) A2(start_p:end_p) A3(start_p:end_p) A4(start_p:end_p)...
              A5(start_p:end_p) A6(start_p:end_p) A7(start_p:end_p) A8(start_p:end_p)];
A_original_f = abs(fft(A_original,N))*2/fs;

f = 0:fs/N:1500-fs/N;
figure(1)
plot(f,A_original_f(1:length(f),1))


%% beamforing analysis

for j = 1:37
    
    incident_angle = (j-1)*5;
    result = plane_beamforming(incident_angle,A_original);
    N_ = length(result);
    f_ = 0:fs/N_:fs/2-fs/N_;
    result_f = abs(fft(result(1:N_,1,1),N_))*2/fs;
    power_(1,j) = 10*log10(sqrt(sum(result_f.^2,1)));
    
end
    
figure(2)
plot(((1:37)-1)*5,10*log10(power_))

incident_angle_1 = 75;
result_1 = plane_beamforming(incident_angle_1,A_original);
N_1 = length(result_1);
f_1 = 0:fs/N_1:1500-fs/N_1;
result_f_1 = abs(fft(result_1(1:N_1,1,1),N_1))*2/fs;
figure(3)
%plot(f_1,20*log10(result_f_1(1:length(f_1))))
plot(f_1,result_f_1(1:length(f_1)))

incident_angle_2 = 102;
result_2 = plane_beamforming(incident_angle_2,A_original);
N_2 = length(result_2);
f_2 = 0:fs/N_2:1500-fs/N_2;
result_f_2 = abs(fft(result_2(1:N_2,1,1),N_2))*2/fs;
figure(4)
%plot(f_2,20*log10(result_f_2(1:length(f_2))))
plot(f_2,result_f_2(1:length(f_2)))