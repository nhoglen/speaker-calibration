rng(20210512) % Initialize RNG for repeatability

testsnip = allfiltsnips{1};

Fsms = Fs/1000;
shuffscale = 5; % chunks to shuffle, ms

nrchunks = ceil(length(testsnip)/(shuffscale*Fsms)); % figure out how many chunks

chunksIdx = randperm(nrchunks); % shuffle
chunkeIdxsamps = chunksIdx.*shuffscale*Fsms; % find end of each chunk in samps
chunkeIdxsamps = chunkeIdxsamps+1; % adjust by 1
chunksIdxsamps = chunkeIdxsamps-shuffscale*Fsms; % find beginning of each chunk
% Adjust end of last chunk to end of signal
[mx,mxidx] = max(chunkeIdxsamps); 
chunkeIdxsamps(mxidx) = length(testsnip);

allIdx = nan(1,length(testsnip));

sidx = 1;

for ii = 1:length(chunksIdxsamps)
    thisslice = chunksIdxsamps(ii):chunkeIdxsamps(ii);
    eidx = sidx+length(thisslice)-1;
    allIdx(sidx:eidx) = chunksIdxsamps(ii):chunkeIdxsamps(ii);
    sidx = eidx+1;
end

shuffsnip = testsnip(allIdx);

figure;
spectrogram(shuffsnip(1:3*Fs),win,overl,0:100:Fs/2,Fs,'yaxis')
% figure;
% spectrogram(testsnip(1:3*Fs),win,overl,0:100:Fs/2,Fs,'yaxis')

%%

rng(20210512) % Initialize RNG for repeatability

testsnip = allfiltsnips{1};

Fsms = Fs/1000;
shuffscale = 5; % chunks to shuffle, ms

nrchunks = ceil(length(testsnip)/(shuffscale*Fsms)); % figure out how many chunks

chunksIdx = randperm(nrchunks); % shuffle
chunkeIdxsamps = chunksIdx.*shuffscale*Fsms; % find end of each chunk in samps
chunkeIdxsamps = chunkeIdxsamps+1; % adjust by 1
chunksIdxsamps = chunkeIdxsamps-shuffscale*Fsms; % find beginning of each chunk
% Adjust end of last chunk to end of signal
[mx,mxidx] = max(chunkeIdxsamps); 
chunkeIdxsamps(mxidx) = length(testsnip);

hanfac = 0.005;
newSound = nan(1,length(testsnip));
sidx = 1;

for ii = 1:length(chunksIdxsamps)
    thisslice = applyHannTaper(testsnip(chunksIdxsamps(ii):chunkeIdxsamps(ii)),Fs,hanfac);
    eidx = sidx+length(thisslice)-1;
    newSound(sidx:eidx) = thisslice;
    sidx = eidx+1;
end

figure;
spectrogram(newSound(1:3*Fs),win,overl,0:100:Fs/2,Fs,'yaxis')
audiowrite('shufftest4.wav',newSound,Fs)

%%

nstest = shuffle_vocal_snip(testsnip,3,Fs);

% figure;
% spectrogram(nstest(1:3*Fs),win,overl,0:100:Fs/2,Fs,'yaxis')
% audiowrite('shufftest5.wav',nstest,Fs)

fc = 60000;
[b,a] = butter(6,fc/(Fs/2),'low');
nstestfilt = filter(b,a,nstest);
figure; spectrogram(rescale(nstestfilt,-1,1),win,overl,0:100:Fs/2,Fs,'yaxis')
% fc2 = 20000;
% [c,d] = butter(6,fc2/(Fs/2),'high');
% nstestfilt2 = filter(c,d,nstestfilt);
% figure; spectrogram(rescale(nstestfilt2,-1,1),win,overl,0:100:Fs/2,Fs,'yaxis')
% audiowrite('shufftest5.wav',nstestfilt2,Fs)

%% Shuffle all vocal snips, filter, and save

allshufflesnips = cell(1,length(allfiltsnips));

for ii = 1:length(allfiltsnips)
    tx = shuffle_vocal_snip(allfiltsnips{ii},3,Fs);
    allshufflesnips{ii} = filter(b,a,tx);
end
