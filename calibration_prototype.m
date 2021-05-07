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
maxs = 125;
sigthresh = 0.05;
plotty = 1;

Xtrim = get_calib_response(calfile,nrReps,probeLen,soundDur,maxs,sigthresh,plotty);

%% Old load process
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
X = rescale(X,-1,1);

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

[prediff,fq] = attenuation_curve(probe,Xtrim(1:end-1)',Fs); % generate attenuation map
precalErr = sum(prediff.^2)/length(prediff);

impr = impulse_response(250000,prediff,fq,[8000 90000],2^10); % generate filter kernel

calib_probe = convnfft(probe, impr); % convolve output signal with filter

calib_probe = rescale(calib_probe,-1,1);

% Plot spectrogram
figure(4);
spectrogram(calib_probe,win,overl,0:100:Fs/2,Fs,'yaxis')

%% Filter calibrated output -- this is unnecessary I think
fc = 6000;
[b,a] = butter(6,fc/(Fs/2),'high');

filtprobe = filter(b,a,calib_probe);
filtprobersc = rescale(filtprobe,-1,1);
figure(8);
spectrogram(filtprobersc,win,overl,0:100:Fs/2,Fs,'yaxis')

%% Save calibrated tone to file

% Used from memory but may be handy to save

%% Play calibrated probe back

% See calibprobe_playback.m, work on making a more integrated playback
% system (eg a function that takes a set of sounds to play... figure out
% whether I can implement a check of windows sound output settings
% specifically for the sampling rate)

% Find a way to generate a record of stimuli played

%% Calculate error
% Load recording of calibrated probe and get out Xtrim

calfile = 'calibrated_logchirp_spk1_vol80.wav';

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
X = rescale(X,-1,1);

% figure(10);
% plot(X);

% Plot amplitude and verify empirically determined trim points
% empstime = 2.637e5;
empstime = find(X>0.05,1,'first');
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

% Calculate error relative to probe
[probe, cfs] = makeLogChirp(8000,90000,1,0,250000); % generate reference tone
[postdiff,fq] = attenuation_curve(probe,Xtrim(1:end-1)',Fs); % generate attenuation map
postcalErr = sum(postdiff.^2)/length(postdiff);

%% Why doesn't calibrated probe produce a smaller error?
[caldiff,fq] = attenuation_curve(probe,calib_probe,Fs); % generate attenuation map


%% Make vocal playback prototype

% Preserve original
% Make calibrated version
% High pass filter both versions for speaker safety
% Try doing a Wiener filter on both versions and see how that playback
% looks

% --> Decide on a final presentation strategy and generate stimuli for
% histology and behavior experiments