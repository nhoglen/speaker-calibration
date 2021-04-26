function xtaper = applyHannTaper(x,Fs,scaleFac)
% applyHannTaper applies a Hann window taper to the beginning and end of a
% sound signal (primarily for the purpose of avoiding click sounds at onset
% and offset).
%
% INPUTS:
% - x: signal to taper (row vector)
% - Fs: sample rate (scalar)
% - scaleFac: scale size of cosine based on Fs (scalar)
%
% OUTPUTS:
% - xtaper: signal with taper applied (row vector)

hwsz = scaleFac * Fs; % set size in samples
wnd = hann(hwsz*2); % synthesize Hann window

xtaper = x;

% apply front half of cosine taper to beginning
xtaper(1:hwsz) = xtaper(1:hwsz).*wnd(1:hwsz)';

% apply back half of cosine taper to end
xtaper(end-hwsz+1) = xtaper(end-hwsz+1).*wnd(end-hwsz+1)';