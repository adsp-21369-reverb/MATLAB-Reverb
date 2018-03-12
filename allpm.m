function [out, rI, wI, buffer, ppi_buffer, ppi_out] = ...
    allpm(in, rI, wI, lfoIndex, excursion, fs, ...
    ppi_buffer, ppi_out, gain, buffer, bufsz)


sine_float = excursion*(cos(2*pi*lfoIndex/fs)-1);
sine_int = round(sine_float);
d = sine_int - sine_float;
a = 0.5; % 0 for linear interpolation, 0.5 suggested

% ***** Välimäki
% h(1) = a*d^2 - a*d;
% h(2) = -a*d^2 + (a-1)*d + 1;
% h(3) = -a*d^2 + (a+1)*d;
% h(4) = h(1);

% ***** J.O.Smith
% h(1) = -(d-1)*(d-2)*(d-3)/6;
% h(2) = d*(d-2)*(d-3)/2;
% h(3) = -d*(d-1)*(d-3)/2;
% h(4) = d*(d-1)*(d-2)/6;

% ***** Spline interpolation
h(1) = (d^3)/6;
h(2) = ((1+d)^3-4*d^3)/6;
h(3) = ((2-d)^3-4*(1-d)^3)/6;
h(4) = ((1-d)^3)/6;

buffer(wI) = in + ppi_out * gain;
ppi_in = buffer(rI);
ppi_buffer = circshift(ppi_buffer,1);
ppi_buffer(1) = ppi_in;
ppi_out = dot(ppi_buffer, h);
out = ppi_out - buffer(wI) * gain;

% ***** w/o interpolation
% buffer(wI) = in + buffer(rI) * gain;
% out = buffer(rI) - buffer(wI) * gain;

bufsz_current = bufsz + sine_int;

rI = mod(rI, bufsz_current) + 1;
wI = mod(wI, bufsz_current) + 1;


% rI = rI + 1;
% wI = wI + 1;
% 
%      if rI > bufsz_current
%         rI=1;
%     end
%     if wI > bufsz_current
%         wI=1;
%     end

end

