% Initialize sound driver
InitializePsychSound(1);

% Set up channels
nrchannels = 1;

% Set up sampling rate
Fs = 192000;

% Start playback immediately (no scheduling)
startCue = 0;

% Volume
vol = 0.02;

% Repetitions
reps = 8;

% ISI
beepPauseTime = 1.5;

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

% Set up sound
% sdat = makeLogChirp(8000,90000,1,0,Fs);
sdat = resample(calib_probe,Fs,250000);

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

for ii = 2:reps    
    
    % Compute new start time for follow-up beep, beepPauseTime after end of
    % previous one
    startCue = estStopTime + beepPauseTime;
    
    % Start audio playback
    PsychPortAudio('Start', pahandle, 1, startCue, waitForDeviceStart);
    
    % Wait for stop of playback
    [actualStartTime, ~, ~, estStopTime] = PsychPortAudio('Stop', pahandle, 1, 1);
    
end

% Close the audio device
PsychPortAudio('Close', pahandle);