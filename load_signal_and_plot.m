%%% Extract mean chirp response from multiple repeats

% Load up first chunk
calfile = 'calibration_linchirp_spk1_vol50.wav';

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
title('Mean amplitude from %d repeats',nrReps)

%%% Plot spectrogram
win = 1024;
overlap = 0.8;
overl = round(overlap*win);
figure(2);
spectrogram(Xtrim,win,overl,0:100:Fs/2,'yaxis')
title('Spectrogram of response')

%%% Plot spectrum
spectrum_response = 20*log10(abs(fft(Xtrim)));
figure(3);
plot(spectrum_response(1:length(spectrum_response)/2))
title('Spectrum of response, dB')