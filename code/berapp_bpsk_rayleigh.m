function [ber, numBits] = berapp_bpsk_rayleigh(EbNo, maxNumErrs, maxNumBits)
% Wrapper function to connect TX.m, rayleigh_channel.m, and RX.m
% to MATLAB's Bit Error Rate Analysis App (bertool).

% === SELECT MODULATION SCHEME FOR BERTOOL HERE ===
mod_scheme = '16QAM';               % Options: 'BPSK', 'QPSK', '16QAM'

totErr = 0;
numBits = 0;

% Convert current EbNo (passed in dB by BERApp) to linear scale
Eb_N0_lin = 10^(EbNo / 10);

% Keep simulating blocks of N bits until max errors or max bits is reached
while (totErr < maxNumErrs) && (numBits < maxNumBits)
    
    % 1. Run Transmitter script
    TX;
    
    % Calculate N0 for the current Eb/N0 point from BERApp
    N0 = Eb / Eb_N0_lin;
    
    % 2. Run Rayleigh Channel script
    rayleigh_channel;
    
    % 3. Run Receiver script
    RX;
    
    % 4. Accumulate bit errors and total bits processed
    BlockErrors = sum(b_k ~= b_hat);
    totErr = totErr + BlockErrors;
    numBits = numBits + N;
    
end

% Compute final BER for this Eb/N0 point
ber = totErr / numBits;
end