function [ button ] = DTMFDecoder( digit )
freqs(1:3) = [697/4000*pi 770/4000*pi 852/4000*pi];
freqs(4:6) = [941/4000*pi 1209/4000*pi 1336/4000*pi];
freqs(7:8) = [1477/4000*pi 1618/4000*pi];
rms = zeros(1,7);
x = DTMFCoder(digit);
for n = 1:7
Wp = freqs(n);
W2 = freqs(n+1);
Wb = W2 - Wp;
R = 1 - (Wb/2);
roots = R * cos(freqs(n)) + R * 1i * sin(freqs(n));
roots(2) = conj(roots(1));
a = poly(roots);
b = 1;
rms(n) = RMS(filter(b, a, x));
end
rms
% Get index of first highest
% Get index of second highest
% Use indecies to acquire value from 2D array representing buttons
% Print value at index of array
end