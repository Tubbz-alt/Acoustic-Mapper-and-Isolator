function [result] = plane_beamforming(incident_angle, A_original)
%   Performing the plane_beamforming algorithm, incident_angle in degree
%   between incident plane wave and microphone array line

    N_beam = 8;
    spacing = 0.2;
    c = 340;
    
    fs = 30100;
    N = 30100;
    
    delta_t = spacing*cos(incident_angle/180*pi)/c;
    delta_point = floor(delta_t*fs);
    Num_max = abs(delta_point)*(N_beam-1);

    A_temp = zeros(N+Num_max,N_beam);
    A_filter = zeros(N,N_beam);
    result = zeros(N-Num_max,1);

    if delta_point > 0
        for i = 1:N_beam
    
            A_temp(1:N+(i-1)*delta_point,i) = [zeros((i-1)*delta_point,1); A_original(:,i)];
            A_filter(:,i) = A_temp(1:N,i); 
            result = result+A_filter(Num_max+1:end,i);
        end
    elseif delta_point<=0
        for i = 1:N_beam
    
            A_temp(1:N+abs((N_beam-i)*delta_point),i) = [zeros((N_beam-i)*abs(delta_point),1); A_original(:,i)];
            A_filter(:,i) = A_temp(1:N,i); 
            result = result+A_filter(Num_max+1:end,i);
        end
    end

end

