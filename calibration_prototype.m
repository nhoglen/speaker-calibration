%%% Extract mean chirp response from multiple repeats

% Load up first chunk
% --- Nightingale
% calfile = fullfile('C:\Users\Nerissa\Documents\Manoli Lab\Audio Testing','calibration_logchirp_spk1_vol80.wav');
calfile = 'calibration_logchirp_spk1_vol80.wav';

% Facts about how the file was generated
nrReps = 45;
probeLen = 2.5;
soundDur = 1;
Fs = 250000;

% Get sample rate and stuff
info = audioinfo(calfile);

maxsamps = 125*Fs; % empirically determined from where probes stop
st = 2*Fs;
et = st+probeLen*Fs; % time stamp empirically determined
[X,Fs] = audioread(calfile,[st et]);

% Loop over reps, adding each subsequent signal
for ii = 2:nrReps
    st = et+1;
    if st+probeLen*Fs < maxsamps
        et = st+probeLen*Fs;
    else
        et = maxsamps;
    end
    [Y,Fs] = audioread(calfile,[st et]);
    sig = Y;
    % Find autocorrelation with existing average
    [x, off] = max(xcorr(X', sig'));
    off = length(X) - off;
    if(off < 0)
        sig = [zeros(1, -off), sig(1:end+off)'];
    elseif (off > 0)
        sig = [sig(off:end)', zeros(1, off-1)]';
    end
    % Add to accumulated data
    if size(sig,1)<size(sig,2)
        sig = sig';
    end
    X = X + sig;
end

% Divide out for mean
X = X/nrReps;

% Plot amplitude and verify empirically determined trim points
empstime = 1.562e5;
Xtrim = X(empstime:empstime+soundDur*Fs);
figure(1); plot(Xtrim)
title(sprintf('Mean amplitude from %d repeats',nrReps))

%%% Plot spectrogram
win = 1024;
overlap = 0.8;
overl = round(overlap*win);
figure(2);
spectrogram(Xtrim,win,overl,0:100:Fs/2,Fs,'yaxis')
title('Spectrogram of response')

%%% Plot spectrum
spectrum_response = 20*log10(abs(fft(Xtrim)));
figure(3);
plot(spectrum_response(1:length(spectrum_response)/2))
title('Spectrum of response, dB')

%% Calibrate
addpath(genpath('CONVNFFT_Folder'))

[probe, cfs] = makeLogChirp(8000,90000,1,0,250000); % generate reference tone

[diffdB,fq] = attenuation_curve(probe,Xtrim(1:end-1)',Fs); % generate attenuation map
precalErr = sum(diffdB.^2)/length(diffdB);

impr = impulse_response(250000,diffdB,fq,[8000 90000],2^10); % generate filter kernel

calib_probe = convnfft(probe, impr); % convolve output signal with filter

% Plot spectrogram
figure(4);
spectrogram(calib_probe,win,overl,0:100:Fs/2,Fs,'yaxis')

%% Save calibrated tone to file

%% Play calibrated probe back

%% Calculate error
% Load recording of calibrated probe and get out Xtrim
[diffdB,fq] = attenuation_curve(probe,newXtrim(1:end-1)',Fs); % generate attenuation map
postcalErr = sum(diffdB.^2)/length(diffdB);