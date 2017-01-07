function [Y] = myFFT(x)

    indices = [0 : length(x)-1];
    revIndices = bin2dec(fliplr(dec2bin(indices, 8))); % bit reversed indices
    revX = x(revIndices + 1);
    temp = zeros(1, length(revX));
    N = 2;
    
    while(N <= length(revX))
        for n = (0:length(revX)/N-1)
            for k = (0:N -1)
                subOff = (N * n);
                even = (mod(k, N/2)) + subOff + 1;
                temp(k + subOff + 1) = revX(even) + (exp(-1i * k * 2 * pi / N) * revX(even + (N/2)));
            end
        end
        revX = temp;
        N = N * 2;
    end
    Y = revX;
end