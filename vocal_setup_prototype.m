% Clean up vocs to play

[vy,Fs] = audioread(fullfile('F:\Manoli Lab\Test Audio Files','day1_pairA3_trimmed602calls.wav'));

% Crop to a clip to test
clipy = vy((2*60+4.3)*Fs:(2*60+06.3)*Fs);

% Wiener filter
clipy_w = WienerScalart96(clipy,Fs,0.35); % last argument says how much time at the beginning to use as silence for filt
win = 1024;
overlap = 0.8;
overl = round(overlap*win);
figure; spectrogram(clipy_w,win,overl,0:100:Fs/2,Fs,'yaxis')

% Calibrate
% Assumes preexistence of impr based on empirical measure of speaker system
clipy_wc = convnfft(clipy_w',impr);
figure; spectrogram(clipy_wc,win,overl,0:100:Fs/2,Fs,'yaxis')

% Butterworth filter
fc = 20000;
[b,a] = butter(6,fc/(Fs/2),'high');
clipy_wcf = filter(b,a,clipy_wc);
figure; spectrogram(clipy_wcf,win,overl,0:100:Fs/2,Fs,'yaxis')

%%

% Calibrate
clipy_c = convnfft(clipy',impr);
win = 1024;
overlap = 0.8;
overl = round(overlap*win);
figure; spectrogram(clipy_c,win,overl,0:100:Fs/2,Fs,'yaxis')

% Wiener filter
clipy_cw = WienerScalart96(clipy_c,Fs,0.1);
figure; spectrogram(clipy_cw,win,overl,0:100:Fs/2,Fs,'yaxis')

% Butterworth filter
fc = 25000;
[b,a] = butter(6,fc/(Fs/2),'high');
clipy_cwf = filter(b,a,clipy_cw);
figure; spectrogram(rescale(clipy_cwf,-1,1),win,overl,0:100:Fs/2,Fs,'yaxis')

%%

figure;spectrogram(clipy,win,overl,0:100:Fs/2,Fs,'yaxis')

%%

audiowrite('wienertest.wav',clipy_wcf,Fs)