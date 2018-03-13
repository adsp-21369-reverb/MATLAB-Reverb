function [out, rI, wI, buffer, ppi_buffer, ppi_out, x_old, y_old, lp_old] = ...
    allpm(in, rI, wI, lfoIndex, excursion, fs, ...
    ppi_buffer, ppi_out, x_old, y_old, lp_old, gain, buffer, bufsz)


sine_float = 2*excursion*(sin(2*pi*lfoIndex/fs)+1); % activate excursion
sine_int = ceil(sine_float);
d = sine_int - sine_float;
a = 0.5; % 0 for linear interpolation, 0.5 suggested

wI = mod(wI, bufsz) + 1;
rI = wI + 1+ sine_int;
rI = mod(rI, bufsz) + 1;

% -------------------------------------------------------
% ***** Compute FIR coefficients *****
% 
% ***** Välimäki approach
% h(1) = a*d^2 - a*d;
% h(2) = -a*d^2 + (a-1)*d + 1;
% h(3) = -a*d^2 + (a+1)*d;
% h(4) = h(1);
% 
% ***** J.O.Smith approach (Lagrange)
% h(1) = -(d-1)*(d-2)*(d-3)/6;
% h(2) = d*(d-2)*(d-3)/2;
% h(3) = -d*(d-1)*(d-3)/2;
% h(4) = d*(d-1)*(d-2)/6;
% 
% ***** Cubic spline interpolation
% h(1) = (d^3)/6;
% h(2) = ((1+d)^3-4*d^3)/6;
% h(3) = ((2-d)^3-4*(1-d)^3)/6;
% h(4) = ((1-d)^3)/6;
% 
% -------------------------------------------------------
% ***** FIR interpolation *****
% 
% buffer(wI) = in + ppi_out * gain;
% ppi_in = buffer(rI);
% ppi_buffer = circshift(ppi_buffer,1);
% ppi_buffer(1) = ppi_in;
% ppi_out = dot(ppi_buffer, h);
% out = ppi_out - buffer(wI) * gain;
% -------------------------------------------------------

% -------------------------------------------------------
% ***** Allpass interpolation *****
% 
% x_new = buffer(rI);
% 
% % *** Simple allpass interpolator:
% y_new = (1-d)*(x_new - y_old) + x_old;
% 
% % *** Warped allpass interpolator:
% % y_new = ((1-d)/(1+d))*(x_new - y_old) + x_old;
% 
% tapout = in + (y_new * gain);
% out = y_new - (tapout * gain);
% buffer(wI) = tapout;
% 
% x_old = x_new;
% y_old = y_new;
% -------------------------------------------------------

% -------------------------------------------------------
% ***** Linear interpolation *****
% 
% lint_out = buffer(rI) * (d) + ppi_out * (1-d);
% buffer(wI) = in + lint_out * gain;
% out = (lint_out - buffer(wI) * gain);
% ppi_out = buffer(rI); % ppi output borrowed: lint_x_old
% -------------------------------------------------------

% -------------------------------------------------------
% ***** No interpolation *****
% 
buffer(wI) = in + buffer(rI) * gain;
out = buffer(rI) - buffer(wI) * gain;
% -------------------------------------------------------

% -------------------------------------------------------
% ***** No interpolation + lowpass after buffer
% 
% b = 0.5;
% lp_out = b*(buffer(rI)+lp_old);
% buffer(wI) = in + lp_out * gain;
% lp_old = buffer(rI);
% out = lp_out - buffer(wI) * gain;
% -------------------------------------------------------


end

