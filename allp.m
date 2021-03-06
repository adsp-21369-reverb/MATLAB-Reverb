function [out, tap, rI, wI, buffer] = allp(in, rI, wI, gain, buffer, bufsz)

buffer(wI) = in - buffer(rI) * gain;
tap = buffer(wI);
out = buffer(wI) * gain + buffer(rI);

rI = mod(rI, bufsz) + 1;
wI = mod(wI, bufsz) + 1;

% rI = rI + 1;
% wI = wI + 1;
% 
%     if rI > bufsz
%         rI=1;
%     end
%     if wI > bufsz
%         wI=1;
%     end

end