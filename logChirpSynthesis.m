winsize = 1024;
overlap = round(.99 * winsize);
figure(20)
specgram(y, winsize, Fs, hann(winsize), overlap)
% specgram(synthdat,winsize,Fs,hann(winsize),overlap)
%%

Fs = 192000;
syllen = 50/1000; % duration in s
totlen = length(y);
totnum = 25;
f1 = 20000;
f2 = 60000;
fc = (f2-f1)/2+f1;

ssamps = totnum*syllen*Fs;
totint = totlen-ssamps;
intcenter = totint/(totnum-1);
ints = intcenter*ones(1,totnum-1);
randadj = (intcenter/10)*(rand(1,totnum-1)-0.5);
intsrand = round(ints+randadj);
if sum(intsrand)>totint
    overflow = sum(intsrand)-totint;
    perint = ceil(overflow/(totnum-1));
    intsrand = intsrand-perint;
end
intsrand(end) = intsrand(end) + (totint-sum(intsrand));

synthdat = nan(1,totlen);
sidx = 1;

for ii = 1:totnum-1
    thisf1 = f1+(fc-f1).*rand(1,1);
    thisf2 = fc+(f2-fc).*rand(1,1);
    [thisStim,~] = makeLogChirp(thisf1,thisf2,syllen,0,Fs);
    thisStim = [thisStim zeros(1,intsrand(ii))];
    eidx = sidx+length(thisStim)-1;
    synthdat(sidx:eidx) = thisStim;
    sidx = eidx+1;
end

thisf1 = f1+(fc-f1).*rand(1,1);
    thisf2 = fc+(f2-fc).*rand(1,1);
    [thisStim,~] = makeLogChirp(thisf1,thisf2,syllen,0,Fs);
synthdat(sidx:end) = thisStim;