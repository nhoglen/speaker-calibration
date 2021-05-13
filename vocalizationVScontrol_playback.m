% Load up stimuli
load('playback_data_calibrated.mat') % --> edit these with calibration and butterworth
allISI = [0 allISI 0]; % pad for the trial structure for psychportaudio

fc = 20000;
[b,a] = butter(6,fc/(Fs/2),'high');

% Initialize sound driver
InitializePsychSound(1);

% Set up channels
nrchannels = 2;

% Set up sampling rate
Fs = 192000;

% Start playback immediately (no scheduling)
startCue = 0;

% Volume
vol = 0.5;

% Should we wait for the device to really start (1 = yes)
% INFO: See help PsychPortAudio
waitForDeviceStart = 1;

% Open Psych-Audio port with arguments
% (1) [] = default sound device; on my system, 4
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo output
pahandle = PsychPortAudio('Open', [], 1, 1, Fs, nrchannels);

% Set the volume
PsychPortAudio('Volume', pahandle, vol);

% Set up initial sound
sdat = makeLogChirp(10000,20000,0.25,0,Fs);

if nrchannels == 2
    sdat = [sdat;sdat];
end

% Fill the playback buffer with the sound data
PsychPortAudio('FillBuffer', pahandle, sdat);

fprintf('Beginning playback.\n\n')

% Start audio playback
PsychPortAudio('Start', pahandle, 1, startCue, waitForDeviceStart);

% Wait for the beep to end. Here we use an improved timing method suggested
% by Mario.
% See: https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/messages/20863
% For more details.
[actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);

for ii = 1:length(allstimshuffle)
% for ii = 1:10 % loop over trials
    
    % Compute new start time for follow-up beep, beepPauseTime after end of
    % previous one
    startCue = estStopTime + allISI(ii);
    
    thisvoc = allcalvocs{allstimshuffle(ii)};
    thisvocf = rescale(filter(b,a,thisvoc),-1,1);
    
    thiscont = allcalshuf{allstimshuffle(ii)};
    thiscontf = rescale(filter(b,a,thiscont),-1,1);
    
    sdat = [resample(thisvocf,Fs,250000)';resample(thiscontf,Fs,250000)'];
    
    % Fill the playback buffer with the sound data
    PsychPortAudio('FillBuffer', pahandle, sdat);
    
    % Start audio playback
    PsychPortAudio('Start', pahandle, 1, startCue, waitForDeviceStart);
    
    % Wait for stop of playback
    [actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
    
end

% Close the audio device
PsychPortAudio('Close', pahandle);