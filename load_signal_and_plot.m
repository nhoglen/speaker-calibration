%%% Extract mean chirp response from multiple repeats

% Load up first chunk
% --- Nightingale
% calfile = fullfile('C:\Users\Nerissa\Documents\Manoli Lab\Audio Testing','calibration_linchirp_spk1_vol50.wav');
% --- Dorian
calfile = fullfile('F:\Manoli Lab\Audio','calibration_linchirp_spk1_vol50.wav');


% Facts about how the file was generated
nrReps = 40;
probeLen = 2.5;
soundDur = 1;
Fs = 250000;

% Get sample rate and stuff
info = audioinfo(calfile);

maxsamps = 120*Fs; % empirically determined from where probes stop
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
        sig = [sig(off:end)', zeros(1, off-1)];
    end
    % Add to accumulated data
    X = X + sig';
end

% Divide out for mean
X = X/nrReps;

% Plot amplitude and verify empirically determined trim points
Xtrim = X(1.375e5:1.375e5+soundDur*Fs);
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

%% Usage

addpath(genpath('CONVNFFT_Folder'))

[probe, cfs] = makeLinearChirp(8000,90000,1,0,250000); % generate reference tone

[diffdB,fq] = attenuation_curve(probe,Xtrim(1:end-1)',Fs); % generate attenuation map

impr = impulse_response(250000,diffdB,fq,[8000 90000],2^10); % generate filter kernel

calib_probe = convnfft(probe, impr); % convolve output signal with filter

% Plot spectrogram
figure(4);
spectrogram(calib_probe,win,overl,0:100:Fs/2,Fs,'yaxis')

%% Test actual recording

[yv,Fsv] = audioread(fullfile('F:\Manoli Lab\Test Audio Files','day1_pairA3_trimmed602calls.wav'));

useclip = yv(95*Fsv:100*Fsv)';

calib_vocs = convnfft(useclip,impr);
figure(5);
spectrogram(calib_vocs,win,overl,0:100:Fsv/2,Fsv,'yaxis')
% soundsc(resample(calib_vocs,44100,Fsv),44100)

% figure(6);
spectrogram(useclip,win,overl,0:100:Fsv/2,Fsv,'yaxis')

% figure(7);
% spectrogram(rescale(calib_vocs,-1,1),win,overl,0:100:Fsv/2,Fsv,'yaxis')

%% Butterworth filtering and rescaling

fc = 20000;
[b,a] = butter(15,fc/(Fsv/2),'high');

filtvocs = filter(b,a,calib_vocs);
filtvocsrsc = rescale(filtvocs,-1,1);
figure(8);
spectrogram(filtvocsrsc,win,overl,0:100:Fsv/2,Fsv,'yaxis')

soundsc(resample(filtvocs,44100,Fsv),44100)

%% Wiener filtering

wclip = yv(95.5*Fsv:100*Fsv)';

wtest = WienerScalart96(wclip,Fsv);

figure(9);
spectrogram(rescale(wtest,-1,1),win,overl,0:100:Fsv/2,Fsv,'yaxis');
