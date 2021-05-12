%% Data entry for the vocal snip times I used for vocal stimulus

stimescell = {[4 31.6;... % pair A1n
    4 41.65;...
    4 58.65;...
    13 12.75;...
    13 21.6];...
    [3 36.6;... % pair A2
    3 46.9;...
    4 08.5;...
    4 28.6;...
    15 24.5;...
    15 30.3;...
    15 46.2;...
    16 03.5];...
    [3 45.85;... % pair A3
    3 52.9;...
    4 10.3;...
    4 19.4;...
    4 23.55;...
    4 41.1;...
    17 30.2];...
    [2 56.3;... % pair A4
    3 04.95;...
    3 07.4;...
    3 14.8;...
    3 20.85;...
    14 21.8;...
    14 27.0;...
    15 47.6]};

etimescell = {[4 35.25;... % pair A1n
    4 44.4;...
    5 02.4;...
    13 17.00;...
    13 23.7];
    [3 39.3;... % pair A2
    3 50.2;...
    4 09.7;...
    4 31.2;...
    15 26.8;...
    15 34.0;...
    15 48.6;...
    16 04.0];...
    [3 52.3;... % pair A3
    3 56.2;...
    4 15.1;...
    4 23.2;...
    4 24.95;...
    4 44.92;...
    17 33.1];...
    [3 01.75;... % pair A4
    3 06.1;...
    3 14.3;...
    3 17.9;...
    3 24.6;...
    14 22.65;...
    14 29.0;...
    15 49.4]};

audfiles = {'day1_pairA1n.wav';...
    'day1_pairA2.wav';...
    'day1_pairA3.wav';...
    'day1_pairA4.wav'};

%% Check data entry for length violations and figure out total time of vocalizations

runsum = 0;
for ii = 1:length(audfiles)
    theses = stimescell{ii};
    thesee = etimescell{ii};
    
    ssecs = theses(:,1)*60+theses(:,2);
    esecs = thesee(:,1)*60+thesee(:,2);
    
    tlen = esecs-ssecs;
    runsum = runsum+sum(tlen);
    % runsum = 86.6700
    
end

%% Generate a Wiener filtered version of each snip

nrsnips = sum(cellfun(@(x) size(x,1),stimescell));
allfiltsnips = cell(1,nrsnips);
recpath = 'F:\Manoli Lab\WT Bonding Vocalizations';
filtlen = 0.2;
% Spectrogram settings
win = 1024;
overlap = 0.8;
overl = round(overlap*win);

% Keep track of where in the cell to put the snip
counter = 1;

for ii = 1:length(audfiles)
    % Set up info for this file
    audfile = audfiles{ii};
    stimes = stimescell{ii};
    etimes = etimescell{ii};
    
    % Get file details
    info = audioinfo(fullfile(recpath,audfile));
    Fs = info.SampleRate;
    
    % Convert minutes/seconds to seconds
    ssecs = stimes(:,1)*60+stimes(:,2);
    esecs = etimes(:,1)*60+etimes(:,2);
    
    % Convert seconds to samples
    ssamps = floor(Fs*ssecs);
    esamps = floor(Fs*esecs);
    
    % Load up first part o f the recording for Wiener filtering
    [filtbit,~] = audioread(fullfile(recpath,audfile),[1 filtlen*Fs]);
    
    % Loop over times
    for jj = 1:length(ssamps)
        snip = audioread(fullfile(recpath,audfile),[ssamps(jj) esamps(jj)]);
        snipf = WienerScalart96([filtbit' snip'],Fs,filtlen);
        %     figure;
        %     spectrogram(snipf,win,overl,0:100:Fs/2,Fs,'yaxis')
        allfiltsnips{counter} = snipf;
        counter = counter+1;
    end   
    
end

%% Generate silence, shuffle, reps

% Going for ~12 mins of stim, which is four repeats of a 3 min cycle of
% vocs and quiet

allstimIDs = repmat(1:nrsnips,1,4);
nrISI = length(allstimIDs)-2;

% Match ISI length distribution to lengths of vocal epochs
minISI = min(cellfun(@length,allfiltsnips)/Fs);
maxISI = max(cellfun(@length,allfiltsnips)/Fs);

rng(20210512) % Initialize RNG for repeatability

allISI = (maxISI-minISI).*rand(1,nrISI)+minISI; % generate random ISIs
allstimshuffle = allstimIDs(randperm(length(allstimIDs))); % shuffle order of vocs

%% Save data to use for real experiments

save('playback_data.mat','allfiltsnips','allISI','allstimshuffle')

%%
recpath = 'F:\Manoli Lab\WT Bonding Vocalizations';
audfile = 'day1_pairA1n.wav';
% enter start and end times for each clip

% Get sample rate for the file
info = audioinfo(fullfile(recpath,audfile));
Fs = info.SampleRate;

% Convert minutes/seconds to seconds
ssecs = stimes(:,1)*60+stimes(:,2);
esecs = etimes(:,1)*60+etimes(:,2);

% Convert seconds to samples
ssamps = Fs*ssecs;
esamps = Fs*esecs;

% Set length of filtering baseline
filtlen = 0.2; % seconds
% Spectrogram settings
win = 1024;
overlap = 0.8;
overl = round(overlap*win);

% Load up first part of the recording for Wiener filtering
[filtbit,~] = audioread(fullfile(recpath,audfile),[1 filtlen*Fs]);

% Loop over times
for ii = 1:length(ssamps)
    snip = audioread(fullfile(recpath,audfile),[ssamps(ii) esamps(ii)]);
    snipf = WienerScalart96([filtbit' snip'],Fs,filtlen);
    figure;
    spectrogram(snipf,win,overl,0:100:Fs/2,Fs,'yaxis')
end

% What else do I need to do?
% x Load up all the snips from each file
% x Save snips
% x Shuffle snips
% x Insert random quiet periods
% x Figure out how many repeats I need
% - Get playback code working with random order and ISIs
% - Figure out scrambling for + control
% - Process snips for calibration and Butterworth (W --> c --> B)