function [out, rI, wI, buffer] = lowp(in, rI, wI, gain, buffer, bufsz)

out = in*gain + buffer(rI)*(1-gain);
buffer(wI) = out;

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

