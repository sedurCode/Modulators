function y = doFilter(x)
%DOFILTER Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 9.5 and DSP System Toolbox 9.7.
% Generated on: 24-Mar-2019 14:00:07

persistent Hd;

if isempty(Hd)
    
    Fpass = 16000000;  % Passband Frequency
    Fstop = 22000000;  % Stopband Frequency
    Apass = 1;         % Passband Ripple (dB)
    Astop = 60;        % Stopband Attenuation (dB)
    Fs    = 48000000;  % Sampling Frequency
    
    h = fdesign.lowpass('fp,fst,ap,ast', Fpass, Fstop, Apass, Astop, Fs);
    
    Hd = design(h, 'equiripple', ...
        'MinOrder', 'any', ...
        'StopbandShape', 'flat');
    
    
    
    set(Hd,'PersistentMemory',true);
    
end

y = filter(Hd,x);

