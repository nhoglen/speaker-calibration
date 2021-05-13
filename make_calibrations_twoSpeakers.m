% Facts about how the file was generated
nrReps = 45;
probeLen = 2.5;
soundDur = 1;
Fs = 250000;
maxs = 130;
sigthresh = 0.05;
st = 1.5*Fs;
plotty = 1;
f0 = 8000;
f1 = 90000;

% Load convolution code
addpath(genpath('CONVNFFT_Folder'))

spk1file = 'calibration5_logchirp_spk1_vol80_8-90kHz.wav';

% Load and calculate
precalX = get_calib_response(spk1file,nrReps,probeLen,soundDur,maxs,sigthresh,st,plotty);

[probe, cfs] = makeLogChirp(f0,f1,1,0,250000); % generate reference tone
[prediff1,fq] = attenuation_curve(probe,precalX(1:end-1)',Fs); % generate attenuation map
% calculate precal error over relevant frequencies
idx1 = find(fq==20000,1,'first');
idx2 = find(fq==60000,1,'first');
precalErr1 = sum(prediff1.^2)/length(prediff1); % calculate mean square error
precalErr1_roi = sum(prediff1(idx1:idx2).^2)/length(prediff1(idx1:idx2));

spk1_impr = impulse_response(192000,prediff1,fq,[f0 f1],2^10); % generate filter kernel

spk2file = 'calibration6_logchirp_spk2_vol80_8-90kHz.wav';

% Load and calculate
precalX = get_calib_response(spk2file,nrReps,probeLen,soundDur,maxs,sigthresh,st,plotty);

[probe, cfs] = makeLogChirp(f0,f1,1,0,250000); % generate reference tone
[prediff2,fq] = attenuation_curve(probe,precalX(1:end-1)',Fs); % generate attenuation map
precalErr2 = sum(prediff2.^2)/length(prediff2); % calculate mean square error
precalErr2_roi = sum(prediff2(idx1:idx2).^2)/length(prediff2(idx1:idx2));

spk2_impr = impulse_response(192000,prediff2,fq,[f0 f1],2^10); % generate filter kernel

% save('calibration_filters.mat','spk1_impr','spk2_impr')