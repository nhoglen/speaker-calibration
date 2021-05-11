%% Calibration process updated May 6, 2021

%% Generate calibration

% Probe response file
% calfile = 'calibration_logchirp_spk1_vol80.wav';
calfile = 'calibration2_logchirp_spk1_vol80.wav';


% Facts about how the file was generated
nrReps = 45;
probeLen = 2.5;
soundDur = 1;
Fs = 250000;
maxs = 130;
sigthresh = 0.05;
st = 2.5*Fs;
plotty = 1;

% Load and calculate
precalX = get_calib_response(calfile,nrReps,probeLen,soundDur,maxs,sigthresh,st,plotty);

% Load convolution code
addpath(genpath('CONVNFFT_Folder'))

% Synthesize probe ground truth
[probe, cfs] = makeLogChirp(8000,90000,1,0,250000); % generate reference tone

[prediff,fq] = attenuation_curve(probe,precalX(1:end-1)',Fs); % generate attenuation map
precalErr = sum(prediff.^2)/length(prediff); % calculate mean square error

% impr = impulse_response(250000,prediff,fq,[8000 90000],2^10); % generate filter kernel
% impr = impulse_response(250000,prediff,fq,[20000 60000],2^10); % generate filter kernel
impr = impulse_response(192000,prediff,fq,[20000 60000],2^10); % generate filter kernel
% impr = impulse_response(192000,prediff,fq,[8000 90000],2^10); % generate filter kernel

calib_probe = convnfft(probe, impr); % convolve output signal with filter

calib_probe = rescale(calib_probe,-1,1);

% Plot spectrogram
figure(4);
win = 1024;
overlap = 0.8;
overl = round(overlap*win);
spectrogram(calib_probe,win,overl,0:100:Fs/2,Fs,'yaxis')
title('Calibrated probe')

%% Calculate error from calibrated recording

postcalfile = 'calibrated6_logchirp_spk1_vol80.wav';

maxs = 120;
st = 1.5*Fs;

% Load and calculate
postcalX = get_calib_response(postcalfile,nrReps,probeLen,soundDur,maxs,sigthresh,st,plotty);

% Calculate error relative to probe
% [probe, cfs] = makeLogChirp(8000,90000,1,0,250000); % generate reference tone
[postdiff,fq] = attenuation_curve(probe,postcalX(1:end-1)',Fs); % generate attenuation map
postcalErr = sum(postdiff.^2)/length(postdiff);