function ber_theo = theoretical_ber(EbNo_dB, mod_type)
% THEORETICAL_BER Calculates the theoretical BER or tight upper bound.
%
%   ber_theo = THEORETICAL_BER(EbNo_dB, mod_type)
%
%   Inputs:
%       EbNo_dB  - Vector or scalar of Eb/N0 values in dB
%       mod_type - 'BPSK', 'QPSK', '8PSK', '16QAM', 'BFSK'
%
%   Outputs:
%       ber_theo - Theoretical Bit Error Rate values

% Standard Q-function implementation via complementary error function (erfc)
% Works on vanilla MATLAB without requiring the Communications Toolbox
Q = @(x) 0.5 * erfc(x / sqrt(2));

% Linear scale Eb/N0
gamma_b = 10.^(EbNo_dB / 10);

switch upper(mod_type)
    case {'BPSK', 'QPSK', 'QPSK_GRAY'}
        % Exact BER for BPSK & Gray-coded QPSK over AWGN:
        % Pb = Q(sqrt(2 * Eb / N0))
        ber_theo = Q(sqrt(2 * gamma_b));

    case '8PSK'
        % Tight upper bound / high-SNR approximation for Gray-coded 8-PSK:
        % Es = 3 * Eb -> gamma_s = 3 * gamma_b
        % Pb ≈ (2 / log2(M)) * Q(sqrt(2 * gamma_s) * sin(pi / 8))
        gamma_s = 3 * gamma_b;
        ber_theo = (2 / 3) * Q(sqrt(2 * gamma_s) * sin(pi / 8));

    case '16QAM'
        % Standard Gray-coded square 16-QAM theoretical BER:
        % Pb ≈ (3 / 8) * Q(sqrt((4/5) * gamma_b))
        ber_theo = (3 / 8) * Q(sqrt((4 / 5) * gamma_b));

    case 'BFSK'
        % Coherent orthogonal BFSK:
        % Pb = Q(sqrt(Eb / N0))
        ber_theo = Q(sqrt(gamma_b));

    otherwise
        error('Unsupported modulation scheme: %s', mod_type);
end

end
