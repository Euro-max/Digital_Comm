function [rx_symbols, noise] = awgn_channel(tx_symbols, EbNo_dB, bits_per_symbol, is_complex)
% AWGN_CHANNEL Adds Additive White Gaussian Noise using MATLAB's randn command.
%
%   [rx_symbols, noise] = AWGN_CHANNEL(tx_symbols, EbNo_dB, bits_per_symbol, is_complex)
%
%   Inputs:
%       tx_symbols      - Vector of transmitted complex/real symbols (normalized Es=1)
%       EbNo_dB         - Ratio of Energy per Bit to Noise Spectral Density in dB
%       bits_per_symbol - Number of information bits carried per symbol (k = log2(M))
%       is_complex      - Boolean, true for complex 2D constellations (default), false for real
%
%   Outputs:
%       rx_symbols      - Received symbols corrupted by AWGN
%       noise           - Generated noise vector
%
%   Section 1.2 requirement: "In MATLAB, the command 'randn' should be used to generate the AWGN."

if nargin < 4
    is_complex = ~isreal(tx_symbols);
end

% Assume transmitted symbols have average energy Es = 1
% Therefore, average bit energy Eb = Es / bits_per_symbol = 1 / k
Eb = mean(abs(tx_symbols).^2) / bits_per_symbol;

% Convert Eb/N0 from dB to linear scale
EbNo_lin = 10^(EbNo_dB / 10);

% Noise power spectral density N0
N0 = Eb / EbNo_lin;

N = length(tx_symbols);

if is_complex
    % Complex noise: Real and Imaginary parts each have variance sigma^2 = N0 / 2
    sigma = sqrt(N0 / 2);
    noise = sigma * (randn(N, 1) + 1j * randn(N, 1));
else
    % Real noise: Variance sigma^2 = N0 / 2
    sigma = sqrt(N0 / 2);
    noise = sigma * randn(N, 1);
end

rx_symbols = tx_symbols + noise;
end
