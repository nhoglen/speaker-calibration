function [x, Fs] = makeLinearChirp(f0,f1,dur,phase,Fs)

c = (f1-f0)/dur; % calculate chirpiness
t = 1/Fs:1/Fs:dur; % synthesize time points
x = sin(phase+2*pi*(c/2*t.^2+f0*t)); % calculate sine wave data for linear chirp
x = applyHannTaper(x,Fs,0.002);