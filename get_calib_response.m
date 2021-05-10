function response = get_calib_response(calfile,nrReps,probeLen,soundDur,maxs,sigthresh,st,plotty)
% get_calib_response finds the mean signal for repeated playback of a probe
% sound.
%
% INPUTS:
% - calfile: sound file with response to analyze
% - nrReps: number of repetitions of the probe to consider
% - probeLen: length of probe trial (including quiet), in seconds
% - soundDur: length of probe (just sound), in seconds
% - maxs: max time in recording to consider, in seconds
% - sigthresh: threshold over which signal amplitude constitutes onset of
%       sound
% - plotty: make plots? 1 or 0
%
% OUTPUTS:
% - response: the mean, rescaled pickup of the probe


% Get sample rate and stuff
info = audioinfo(calfile);

Fs = info.SampleRate;

maxsamps = maxs*Fs; % convert signal end time to samples

% st = 2*Fs; % hardcoded: start sampling 2 seconds after start of recording
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

% Divide out for mean and rescale for consistency
X = X/nrReps;
X = rescale(X,-1,1);

% Trim to signal
tstime = find(X>sigthresh,1,'first');
response = X(tstime:tstime+soundDur*Fs);

if plotty
    figure(1); plot(response)
    title(sprintf('Mean amplitude from %d repeats',nrReps))

    %%% Plot spectrogram
    win = 1024;
    overlap = 0.8;
    overl = round(overlap*win);
    figure(2);
    spectrogram(response,win,overl,0:100:Fs/2,Fs,'yaxis')
    title('Spectrogram of response')

    %%% Plot spectrum
    spectrum_response = 20*log10(abs(fft(response)));
    figure(3);
    plot(spectrum_response(1:length(spectrum_response)/2))
    title('Spectrum of response, dB')
end
