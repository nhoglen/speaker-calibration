function newSound = shuffle_vocal_snip(snip,shuffscale,Fs)
% shuffle_vocal_snip shuffles a recording in chunks.
% 
% INPUTS:
% - snip: signal
% - shuffscale: how many ms to preserve in a chunk
% - Fs: sampling rate
%
% OUTPUTS:
% - newSound: shuffled signal

Fsms = Fs/1000; % sampling rate in ms

nrchunks = ceil(length(snip)/(shuffscale*Fsms)); % figure out how many chunks

% Make the chunks and shuffle
chunksIdx = randperm(nrchunks); % shuffle
chunkeIdxsamps = chunksIdx.*shuffscale*Fsms; % find end of each chunk in samps
chunkeIdxsamps = chunkeIdxsamps+1; % adjust by 1
chunksIdxsamps = chunkeIdxsamps-shuffscale*Fsms; % find beginning of each chunk
% Adjust end of last chunk to end of signal
[mx,mxidx] = max(chunkeIdxsamps); 
chunkeIdxsamps(mxidx) = length(snip);

% Set params to Hann window to minimize clicking
% hwsz = scaleFac * Fs; % set size in samples
hwszmx = floor(shuffscale/2); % based on size of sample, figure out max window size
facmax = hwszmx/Fs; % how large can the factor be
hanfac = min(0.05,facmax);

newSound = nan(1,length(snip));

% Loop over chunks to window and arrange
sidx = 1;
for ii = 1:length(chunksIdxsamps)
    thisslice = snip(chunksIdxsamps(ii):chunkeIdxsamps(ii));
    if length(thisslice)==shuffscale*Fsms
        thisslice = applyHannTaper(snip(chunksIdxsamps(ii):chunkeIdxsamps(ii)),Fs,hanfac);
    end
    % Update indexing
    eidx = sidx+length(thisslice)-1;
    newSound(sidx:eidx) = thisslice;
    sidx = eidx+1;
end