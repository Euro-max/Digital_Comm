function [rx_symbols, noise] = awgn_channel(tx_symbols, EbNo_dB, k)
% AWGN_CHANNEL Passes baseband symbols through an Additive White Gaussian Noise channel.
%
% Inputs:
%   tx_symbols - Vector of transmitted complex baseband symbols (normalized to Es = 1)
%   EbNo_dB    - Energy per bit to noise power spectral density ratio (Eb/N0) in dB
%   k          - Number of bits per symbol (log2(M)), returned by mapper.m
%
% Outputs:
%   rx_symbols - Received noisy complex baseband symbols
%   noise      - Generated complex AWGN vector (optional output for inspection)

    % 1. Convert Eb/N0 from dB to linear scale
    EbNo_lin = 10^(EbNo_dB / 10);

    % 2. Calculate bit energy (Eb) from normalized average symbol energy (Es = 1)
    Es = 1;
    Eb = Es / k;

    % 3. Calculate one-sided noise power spectral density (N0)
    N0 = Eb / EbNo_lin;

    % 4. Calculate noise standard deviation per dimension (I and Q)
    % Each orthogonal dimension has variance sigma^2 = N0 / 2
    sigma = sqrt(N0 / 2);

    % 5. Generate complex AWGN using randn (as required by the project)
    noise_I = sigma * randn(size(tx_symbols));
    noise_Q = sigma * randn(size(tx_symbols));
    noise = noise_I + 1j * noise_Q;

    % 6. Add noise to the transmitted signal
    rx_symbols = tx_symbols + noise;
end

