function [x, Fs] = makeLogChirp(f0,f1,dur,phase,Fs)

k = (f1/f0)^(1/dur); % calculate change of frequency 
t = 1/Fs:1/Fs:dur; % synthesize time points
x = sin(phase+2*pi*f0*((k.^t-1)/log(k))); % calculate sine wave data for log chirp
x = applyHannTaper(x,Fs,0.002);