function ber = theoretical_ber(EbNo_dB, mod_type)
% THEORETICAL_BER Computes theoretical BER (or tight upper bound) in AWGN.
%
% Inputs:
%   EbNo_dB  - Scalar or vector of Eb/N0 values in dB
%   mod_type - String specifying the modulation scheme:
%              'BPSK', 'QPSK', 'QPSK_NONGRAY', '8PSK', '16QAM', 'BFSK'
%
% Output:
%   ber      - Theoretical Bit Error Rate corresponding to EbNo_dB

    % Convert Eb/N0 from dB to linear scale (vectorized)
    gamma_b = 10.^(EbNo_dB / 10);

    % Normalize modulation string
    mod_type = upper(strtrim(mod_type));

    % Note: Uses built-in erfc to avoid Communications Toolbox (qfunc)
    % Identity: Q(x) = 0.5 * erfc(x / sqrt(2))
    switch mod_type
        case 'BPSK'
            % Exact BER: Q(sqrt(2 * Eb/N0))
            ber = 0.5 * erfc(sqrt(gamma_b));

        case 'QPSK'
            % Exact BER for Gray-coded QPSK (Figure 2): identical to BPSK
            ber = 0.5 * erfc(sqrt(gamma_b));

        case 'QPSK_NONGRAY'
            % Exact BER for Non-Gray QPSK (Figure 3):
            % Let p = Q(sqrt(2 * Eb/N0)) be the single-axis error probability.
            % Adjacent crossing along Q gives 1 bit error; along I gives 2 bit errors;
            % diagonal crossing gives 1 bit error -> Pb = (3/2)*p - p^2
            p = 0.5 * erfc(sqrt(gamma_b));
            ber = 1.5 * p - p.^2;

        case '8PSK'
            % Tight upper bound / high-SNR approximation for Gray-coded 8PSK:
            % Ps <= 2 * Q(sqrt(2 * k * Eb/N0) * sin(pi/M)), Pb approx Ps / k (k=3, M=8)
            ber = (1/3) * erfc(sqrt(3 * gamma_b) * sin(pi / 8));

        case '16QAM'
            % Tight approximation for Gray-coded 16-QAM:
            % Ps approx 3 * Q(sqrt(4/5 * Eb/N0)), Pb approx Ps / 4
            ber = (3/8) * erfc(sqrt((2/5) * gamma_b));

        case 'BFSK'
            % Exact BER for coherent orthogonal BFSK: Q(sqrt(Eb/N0))
            ber = 0.5 * erfc(sqrt(gamma_b / 2));

        otherwise
            error('Unsupported modulation type: %s', mod_type);
    end
end