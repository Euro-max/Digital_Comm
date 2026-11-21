function [symbols, k, constellation] = mapper(bits, mod_type)
% MAPPER Maps a binary bit stream to normalized baseband complex symbols.
%
% Inputs:
%   bits     - Row or column vector of binary bits (0s and 1s)
%   mod_type - String specifying the modulation scheme:
%              'BPSK', 'QPSK', 'QPSK_NONGRAY', '8PSK', '16QAM', 'BFSK'
%
% Outputs:
%   symbols       - Row vector of complex baseband symbols (Avg. Energy Es = 1)
%   k             - Number of bits per symbol (log2(M))
%   constellation - Lookup table of all M constellation points indexed by
%                   (decimal_bit_value + 1), useful for the demapper.

    % Ensure input bits are a row vector
    bits = bits(:).';
    
    % Normalize modulation type string to uppercase for safety
    mod_type = upper(strtrim(mod_type));

    % Define bits per symbol (k) and constellation lookup table (Es = 1)
    % Index in constellation corresponds to: decimal(b0 b1 ... b_{k-1}) + 1
    switch mod_type
        case 'BPSK'
            k = 1;
            % 0 -> -1, 1 -> +1
            constellation = [-1, 1];

        case 'QPSK'
            % Gray-coded QPSK (Figure 2)
            % 00 -> (-1 - 1j)/sqrt(2),  01 -> (-1 + 1j)/sqrt(2)
            % 10 -> (+1 - 1j)/sqrt(2),  11 -> (+1 + 1j)/sqrt(2)
            k = 2;
            constellation = [ ...
                -1 - 1j, ... % 00 (index 1)
                -1 + 1j, ... % 01 (index 2)
                 1 - 1j, ... % 10 (index 3)
                 1 + 1j  ... % 11 (index 4)
            ] / sqrt(2);

        case 'QPSK_NONGRAY'
            % Non-Gray QPSK (Figure 3)
            % 00 -> (-1 - 1j)/sqrt(2),  01 -> (-1 + 1j)/sqrt(2)
            % 10 -> (+1 + 1j)/sqrt(2),  11 -> (+1 - 1j)/sqrt(2)
            k = 2;
            constellation = [ ...
                -1 - 1j, ... % 00 (index 1)
                -1 + 1j, ... % 01 (index 2)
                 1 + 1j, ... % 10 (index 3)
                 1 - 1j  ... % 11 (index 4)
            ] / sqrt(2);

        case '8PSK'
            % Gray-coded 8PSK (Figure 2)
            % Angles counter-clockwise:
            % 000: 0,    001: pi/4,   011: pi/2,   010: 3*pi/4
            % 110: pi,   111: 5*pi/4, 101: 3*pi/2, 100: 7*pi/4
            k = 3;
            angles = [ ...
                0,      ... % 000 (index 1)
                pi/4,   ... % 001 (index 2)
                3*pi/4, ... % 010 (index 3)
                pi/2,   ... % 011 (index 4)
                7*pi/4, ... % 100 (index 5)
                3*pi/2, ... % 101 (index 6)
                pi,     ... % 110 (index 7)
                5*pi/4  ... % 111 (index 8)
            ];
            constellation = exp(1j * angles);

        case '16QAM'
            % Gray-coded 16-QAM (Figure 2): bits [b0 b1 b2 b3]
            % b0 b1 -> I axis: 00->-3, 01->-1, 10->+3, 11->+1
            % b2 b3 -> Q axis: 00->-3, 01->-1, 10->+3, 11->+1
            k = 4;
            I_levels = [-3, -1, 3, 1];
            Q_levels = [-3, -1, 3, 1];
            
            constellation = zeros(1, 16);
            for idx = 0:15
                I_idx = floor(idx / 4) + 1; % Top 2 bits (b0 b1)
                Q_idx = mod(idx, 4) + 1;    % Bottom 2 bits (b2 b3)
                constellation(idx + 1) = I_levels(I_idx) + 1j * Q_levels(Q_idx);
            end
            % Normalize average symbol energy Es to 1 (unnormalized Es = 10)
            constellation = constellation / sqrt(10);

        case 'BFSK'
            % Orthogonal Baseband BFSK in 2D signal space (phi_1, phi_2)
            % 0 -> 1 + 0j (along phi_1), 1 -> 0 + 1j (along phi_2)
            k = 1;
            constellation = [1 + 0j, 0 + 1j];

        otherwise
            error('Unsupported modulation type: %s', mod_type);
    end

    % Verify that the bit stream length is divisible by k
    if mod(length(bits), k) ~= 0
        error('Input bit length (%d) must be a multiple of k = %d for %s.', ...
              length(bits), k, mod_type);
    end

    % Group bits into blocks of k bits (each row is one symbol)
    bit_groups = reshape(bits, k, []).';

    % Convert each k-bit row to its decimal index (0 to M-1)
    % Avoids Communications Toolbox dependency (bi2de)
    weights = 2.^(k-1 : -1 : 0).';
    sym_indices = (bit_groups * weights).' + 1;

    % Map indices directly to complex baseband symbols
    symbols = constellation(sym_indices);
end

