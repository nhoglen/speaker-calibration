function [diffdB, fq] = attenuation_curve(signal,resp,fs)
% Calculate attenuation roll-off curve for a sound system based on a probe
% signal and a recording of that signal.
%
% INPUTS:
% signal: probe signal sent to speakers
% resp: response recorded from speakers
% fs: sample rate of input and output (needs to match)
% calf: frequency to use as 0 attenuation
%
% OUTPUTS:
% diffdB: difference between reference and record
% fq: frequencies in analysis

% remove DC offset
resp = resp-mean(resp);

y = resp;
x = signal;

L = length(y);

% Do FFT for both signals
Y = fft(y);
X = fft(x);

% Take magnitudes
Ymag = abs(Y/L);
Xmag = abs(X/L);
Ymag = Ymag(1:L/2+1);
Xmag = Xmag(1:L/2+1);

% Convert to decibels
YmagdB = 20*log10(Ymag);
XmagdB = 20*log10(Xmag);

% Difference gives the attenuation curve
% diffdB = XmagdB-YmagdB;
diffdB = YmagdB-XmagdB;

% Find frequencies present in the signal
npts = length(y);
fq = 1:(npts/2+1);
fq = fq/(npts/fs);
fq = fq-1;