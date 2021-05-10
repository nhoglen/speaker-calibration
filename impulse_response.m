function impulse_response2 = impulse_response(genrate,fresponse,frequencies,frange,filter_len)
% Calculate a filter kernel based on a vector representing the attenuations
% at each frequency for a sound response system.
%
% INPUTS:
% - genrate: sample rate at which the test signal was generated
% - fresponse: vector of relative attenuations of frequencies
% - frequencies: frequencies corresponding to the fresponse
% - frange: min and max frequencies at which to apply filter kernel
% - filter_len: length for generated impulse response
%
% OUTPUTS:
% - impulse_response: vector of impulse_response

freq = frequencies;
max_freq = genrate/2+1; % Nyquist frequency

attenuations = zeros(1,length(fresponse)); % initialize

winsz = 0.05; % percent

% Find low and high frequencies
lowf = max(0,frange(1)-(frange(2)-frange(1))*winsz);
highf = min(frequencies(end),frange(2)+(frange(2)-frange(1))*winsz);

% Find frequency positions
[~,f0] = min(abs(freq-lowf));
[~,f1] = min(abs(freq-highf));
[~,fmax]  = min(abs(freq-max_freq));

% Tukey window frequency response
tw1 = tukeywin(length(fresponse(f0:f1)),winsz);
attenuations(f0:f1) = fresponse(f0:f1).*tw1';

% Un-decibel freq response and trim
freq_response = 10.^(attenuations/20);
freq_response = freq_response(1:fmax);

% Invert FFT
impulse_response = ifft(freq_response,'symmetric');
% Take real part
% impulse_response = abs(impulse_response/length(freq_response));

% Rotate for causal filter
impulse_response2 = circshift(impulse_response,floor(length(impulse_response)/2));

% Truncate
if filter_len>length(impulse_response2)
    filter_len = length(impulse_response2);
end
startidx = (floor(length(impulse_response2)/2))-(floor(filter_len/2));
stopidx = (floor(length(impulse_response2)/2))+(floor(filter_len/2));
impulse_response2 = impulse_response2(startidx:stopidx);

% Window the impulse_response
tw2 = tukeywin(length(impulse_response2),0.05);
impulse_response2 = impulse_response2.*tw2';