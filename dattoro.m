clear all; close all; clc;

% fetch file
file.name_in = 'gender1.wav';   % input file name
file.name_out = 'gender1_reverb100_mix02_spline.wav';    % output file name
mix = 0.2;	% mix factor: wet=1.0, dry=0.0

[file.in, file.fs] = audioread(file.name_in);

% reverb parameters
silenceSeconds = 1; % append silence in seconds
file.fs_convert = file.fs / 29761;
excursion = 0; % deactivate mod. delayline with excursion = 0;
% excursion = round(8 * file.fs_convert); 
g1 = 0.75;	%input diffusion 1 [0.75]
g2 = 0.625;	%input diffusion 2 [0.625]
g3 = 0.5;	%decay diffusion 2 [0.5]
g4 = 0.7;	%decay diffusion 1 [0.7]
g5 = 0.5;	%decay [0.5]
bandwidth = 0.9995; % [0.9995]
damping = 0.0005; %[0.0005]

% make stereo if mono
if size(file.in,2) ==1
    file.in(:,2) = file.in(:,1);
end

file.in_old = file.in;
file.left = file.in(:,1);
file.right = file.in(:,2);
if size(file.in, 1) > size(file.in, 2)
	blksz = size(file.in, 1);
else
	blksz = size(file.in, 2);
end

% append zeros for reverberating tail:
nzeros = round(silenceSeconds * file.fs);
blksz_old = blksz;
file.in(blksz+1:blksz+nzeros,1) = 0;
file.in(blksz+1:blksz+nzeros,2) = 0;
file.left(blksz+1:blksz+nzeros) = 0;
file.right(blksz+1:blksz+nzeros) = 0;
blksz = size(file.in, 1);

% compute buffersizes

lp1.bufsz = round(1 * file.fs_convert) + 2;
ap1.bufsz = round(142 * file.fs_convert) + 2;
ap2.bufsz = round(107 * file.fs_convert) + 2;
ap3.bufsz = round(379 * file.fs_convert) + 2;
ap4.bufsz = round(277 * file.fs_convert) + 2;
%
apm1.bufsz = round(672 * file.fs_convert) + 2 + 2*excursion;
d1.bufsz = round(4453 * file.fs_convert) + 2;
lp2.bufsz = round(1 * file.fs_convert) + 2;
ap5.bufsz = round(1800 * file.fs_convert) + 2;
d2.bufsz = round(3720 * file.fs_convert) + 2;
%
apm2.bufsz = round(908 * file.fs_convert) + 2 + 2*excursion;
d3.bufsz = round(4217 * file.fs_convert) + 2;
lp3.bufsz = round(1 * file.fs_convert) + 2;
ap6.bufsz = round(2656 * file.fs_convert) + 2;
d4.bufsz = round(3163 * file.fs_convert) + 2;
%
d5.bufsz = round(266 * file.fs_convert) + 2;
d6.bufsz = round(2974 * file.fs_convert) + 2;
d7.bufsz = round(1913 * file.fs_convert) + 2;
d8.bufsz = round(1996 * file.fs_convert) + 2;
d9.bufsz = round(1990 * file.fs_convert) + 2;
d10.bufsz = round(187 * file.fs_convert) + 2;
d11.bufsz = round(1066 * file.fs_convert) + 2;
%
d12.bufsz = round(353 * file.fs_convert) + 2;
d13.bufsz = round(3627 * file.fs_convert) + 2;
d14.bufsz = round(1228 * file.fs_convert) + 2;
d15.bufsz = round(2673 * file.fs_convert) + 2;
d16.bufsz = round(2111 * file.fs_convert) + 2;
d17.bufsz = round(335 * file.fs_convert) + 2;
d18.bufsz = round(121 * file.fs_convert) + 2;

% init buffers

reverb.in(1 : blksz) = 0;
lp1.buffer = zeros(1, lp1.bufsz);
ap1.buffer = zeros(1, ap1.bufsz);
ap2.buffer = zeros(1, ap2.bufsz);
ap3.buffer = zeros(1, ap3.bufsz);
ap4.buffer  = zeros(1, ap4.bufsz);
% ***
apm1.buffer  = zeros(1, apm1.bufsz);
%apm1.bufsz = apm1.bufsz;% - 2 - excursion;
%apm1.out = 0; apm1.oldout = 0;
d1.buffer  = zeros(1, d1.bufsz);
lp2.buffer  = zeros(1, lp2.bufsz);
ap5.buffer  = zeros(1, ap5.bufsz);
d2.buffer  = zeros(1, d2.bufsz);
% ***
apm2.buffer  = zeros(1, apm2.bufsz);
%apm2.bufsz = apm2.bufsz;% - 2 - excursion;
%apm2.out = 0; apm2.oldout = 0;
d3.buffer  = zeros(1, d3.bufsz);
lp3.buffer  = zeros(1, lp3.bufsz);
ap6.buffer  = zeros(1, ap6.bufsz);
d4.buffer  = zeros(1, d4.bufsz);
% ***
d5.buffer  = zeros(1, d5.bufsz);
d6.buffer  = zeros(1, d6.bufsz);
d7.buffer  = zeros(1, d7.bufsz);
d8.buffer  = zeros(1, d8.bufsz);
d9.buffer  = zeros(1, d9.bufsz);
d10.buffer  = zeros(1, d10.bufsz);
d11.buffer  = zeros(1, d11.bufsz);
% ***
d12.buffer  = zeros(1, d12.bufsz);
d13.buffer  = zeros(1, d13.bufsz);
d14.buffer  = zeros(1, d14.bufsz);
d15.buffer  = zeros(1, d15.bufsz);
d16.buffer  = zeros(1, d16.bufsz);
d17.buffer  = zeros(1, d17.bufsz);
d18.buffer  = zeros(1, d18.bufsz);
%
d1.tap = 0; ap5.tap = 0; d2.tap = 0;
d3.tap = 0; ap6.tap = 0; d4.tap = 0;
%
tank.leftout = 0;
tank.rightout = 0;
%
reverb.out(1 : blksz, 1) = 0;
reverb.out(1 : blksz, 2) = 0;

% init pointers

lp1.wI = 1; lp1.rI = 2;
ap1.wI = 1; ap1.rI = 2;
ap2.wI = 1; ap2.rI = 2;
ap3.wI = 1; ap3.rI = 2;
ap4.wI = 1; ap4.rI = 2;
%
apm1.wI = 1; apm1.rI = 2;
d1.wI = 1; d1.rI = 2;
lp2.wI = 1; lp2.rI = 2;
ap5.wI = 1; ap5.rI = 2;
d2.wI = 1; d2.rI = 2;
%
apm2.wI = 1; apm2.rI = 2;
d3.wI = 1; d3.rI = 2;
lp3.wI = 1; lp3.rI = 2;
ap6.wI = 1; ap6.rI = 2;
d4.wI = 1; d4.rI = 2;
%
d5.wI = 1; d5.rI = 2;
d6.wI = 1; d6.rI = 2;
d7.wI = 1; d7.rI = 2;
d8.wI = 1; d8.rI = 2;
d9.wI = 1; d9.rI = 2;
d10.wI = 1; d10.rI = 2;
d11.wI = 1; d11.rI = 2;
%
d12.wI = 1; d12.rI = 2;
d13.wI = 1; d13.rI = 2;
d14.wI = 1; d14.rI = 2;
d15.wI = 1; d15.rI = 2;
d16.wI = 1; d16.rI = 2;
d17.wI = 1; d17.rI = 2;
d18.wI = 1; d18.rI = 2;

sine.lfoIndex = 1;
sine.excursion = excursion;
sine.fs = file.fs; % 1Hz LFO delay modulation; file.fs/2 for 0.5Hz

apm1.ppi_buffer = zeros(1,4);
apm2.ppi_buffer = zeros(1,4);
apm1.ppi_out = 0;
apm2.ppi_out = 0;


% signal processing

tic;

i = 1;
while i <= blksz
    
	reverb.in(i) = 0.5 * (file.left(i) + file.right(i)); % *0.5
    
    % Input Diffusion
	[lp1.out, lp1.rI, lp1.wI, lp1.buffer] = lowp(reverb.in(i), lp1.rI, lp1.wI, bandwidth, lp1.buffer, lp1.bufsz);
    [ap1.out, ap1.tap, ap1.rI, ap1.wI, ap1.buffer] = allp(lp1.out, ap1.rI, ap1.wI, g1, ap1.buffer, ap1.bufsz); % returnvariablen: ausgang, tapout, pointer
    [ap2.out, ap2.tap, ap2.rI, ap2.wI, ap2.buffer] = allp(ap1.out, ap2.rI, ap2.wI, g1, ap2.buffer, ap2.bufsz); % input: outs, buffers + sz, lookup, pointers
	[ap3.out, ap3.tap, ap3.rI, ap3.wI, ap3.buffer] = allp(ap2.out, ap3.rI, ap3.wI, g2, ap3.buffer, ap3.bufsz);
	[ap4.out, ap4.tap, ap4.rI, ap4.wI, ap4.buffer] = allp(ap3.out, ap4.rI, ap4.wI, g2, ap4.buffer, ap4.bufsz);
    
    % Tank feedback input
	tank.leftin = tank.rightout + ap4.out;
	tank.rightin = tank.leftout + ap4.out;
    
    % Left Tank
    [apm1.out, apm1.rI, apm1.wI, apm1.buffer, apm1.ppi_buffer, apm1.ppi_out] = ...
        allpm(tank.leftin, apm1.rI, apm1.wI, sine.lfoIndex, sine.excursion, ...
        file.fs, apm1.ppi_buffer, apm1.ppi_out, g4, apm1.buffer, apm1.bufsz);
    [d1.out, d1.tap, d1.rI, d1.wI, d1.buffer] = del(apm1.out, d1.rI, d1.wI, d1.buffer, d1.bufsz);
	[lp2.out, lp2.rI, lp2.wI, lp2.buffer] = lowp(d1.out, lp2.rI, lp2.wI, (1-damping), lp2.buffer, lp2.bufsz);
    lp2.out = lp2.out * g5;
	[ap5.out, ap5.tap, ap5.rI, ap5.wI, ap5.buffer] = allp(lp2.out, ap5.rI, ap5.wI, g3, ap5.buffer, ap5.bufsz);
	[d2.out, d2.tap, d2.rI, d2.wI, d2.buffer] = del(ap5.out, d2.rI, d2.wI, d2.buffer, d2.bufsz);
	tank.leftout = d2.out * g5;
	
    % Right Tank
	[apm2.out, apm2.rI, apm2.wI, apm2.buffer, apm2.ppi_buffer, apm2.ppi_out] = ...
        allpm(tank.rightin, apm2.rI, apm2.wI, sine.lfoIndex, sine.excursion, ...
        file.fs, apm2.ppi_buffer, apm2.ppi_out, g4, apm2.buffer, apm2.bufsz);
    [d3.out, d3.tap, d3.rI, d3.wI, d3.buffer] = del(apm2.out, d3.rI, d3.wI, d3.buffer, d3.bufsz);
	[lp3.out, lp3.rI, lp3.wI, lp3.buffer] = lowp(d3.out, lp3.rI, lp3.wI, (1-damping), lp3.buffer, lp3.bufsz);
    lp3.out = lp3.out * g5;
	[ap6.out, ap6.tap, ap6.rI, ap6.wI, ap6.buffer] = allp(lp3.out, ap6.rI, ap6.wI, g3, ap6.buffer, ap6.bufsz);
	[d4.out, d4.tap, d4.rI, d4.wI, d4.buffer] = del(ap6.out, d4.rI, d4.wI, d4.buffer, d4.bufsz);
	tank.rightout = d4.out * g5;
    
    % Delay Network
    [d5.out, d5.tap, d5.rI, d5.wI, d5.buffer] = del(d1.tap, d5.rI, d5.wI, d5.buffer, d5.bufsz);
    [d6.out, d6.tap, d6.rI, d6.wI, d6.buffer] = del(d1.tap, d6.rI, d6.wI, d6.buffer, d6.bufsz);
	[d7.out, d7.tap, d7.rI, d7.wI, d7.buffer] = del(ap5.tap, d7.rI, d7.wI, d7.buffer, d7.bufsz);
	[d8.out, d8.tap, d8.rI, d8.wI, d8.buffer] = del(d2.tap, d8.rI, d8.wI, d8.buffer, d8.bufsz);
	[d9.out, d9.tap, d9.rI, d9.wI, d9.buffer] = del(d3.tap, d9.rI, d9.wI, d9.buffer, d9.bufsz);
	[d10.out, d10.tap, d10.rI, d10.wI, d10.buffer] = del(ap6.tap, d10.rI, d10.wI, d10.buffer, d10.bufsz);
	[d11.out, d11.tap, d11.rI, d11.wI, d11.buffer] = del(d4.tap, d11.rI, d11.wI, d11.buffer, d11.bufsz);
	[d12.out, d12.tap, d12.rI, d12.wI, d12.buffer] = del(d3.tap, d12.rI, d12.wI, d12.buffer, d12.bufsz);
	[d13.out, d13.tap, d13.rI, d13.wI, d13.buffer] = del(d3.tap, d13.rI, d13.wI, d13.buffer, d13.bufsz);
	[d14.out, d14.tap, d14.rI, d14.wI, d14.buffer] = del(ap6.tap, d14.rI, d14.wI, d14.buffer, d14.bufsz);
	[d15.out, d15.tap, d15.rI, d15.wI, d15.buffer] = del(d4.tap, d15.rI, d15.wI, d15.buffer, d15.bufsz);
	[d16.out, d16.tap, d16.rI, d16.wI, d16.buffer] = del(d1.tap, d16.rI, d16.wI, d16.buffer, d16.bufsz);
	[d17.out, d17.tap, d17.rI, d17.wI, d17.buffer] = del(ap5.tap, d17.rI, d17.wI, d17.buffer, d17.bufsz);
	[d18.out, d18.tap, d18.rI, d18.wI, d18.buffer] = del(d2.tap, d18.rI, d18.wI, d18.buffer, d18.bufsz);
    
    %
	reverb.out(i,1) = d5.out + d6.out - d7.out + d8.out - d9.out - d10.out - d11.out;
	reverb.out(i,2) = d12.out + d13.out - d14.out + d15.out - d16.out - d17.out - d18.out;
    
	% sine pointer, current sine value update
    sine.lfoIndex = mod(sine.lfoIndex, sine.fs) + 1;
    

i=i+1;
end


file.processtime = toc;
file.processtimepercycle = file.processtime/i;
file.seconds = blksz / file.fs;
file.seconds_old = blksz_old / file.fs;
file.processtimeperseconds = file.processtime/file.seconds;

file.out = file.in * (1-mix) + reverb.out * mix;

%file.out = transpose(file.out);
audiowrite(file.name_out, file.out, file.fs);
%% Plot logarithmic timesignal
t_vec = 0:1/file.fs:(length(file.out)-1)/file.fs;
figure(1)
plot(t_vec, (file.in));
figure(2)
plot(t_vec, ((file.out))); grid on;
%% Impulse Response Stem
figure;
stem(file.in); hold on; grid on;
stem(file.out);
ylim([-1.2 1.2]);
xlim([-1 1E4]);
legend('Input Left', 'Input Right', 'Output Left', 'Output Right');
%%
sound(reverb.out, file.fs);
