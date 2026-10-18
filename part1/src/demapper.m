function rx_bits = demapper(rx_symbols, mod_type)
% DEMAPPER Maximum Likelihood (Minimum Euclidean Distance) symbol demapper.
%
%   rx_bits = DEMAPPER(rx_symbols, mod_type)
%
%   Inputs:
%       rx_symbols - Vector of complex symbols corrupted by AWGN
%       mod_type   - 'BPSK', 'QPSK_Gray', 'QPSK_NonGray', '8PSK', '16QAM'
%
%   Outputs:
%       rx_bits    - Column vector of recovered binary bits

rx_symbols = rx_symbols(:);

switch upper(mod_type)
    case 'BPSK'
        % Decision boundary: Real(y) > 0 -> bit 1, else bit 0
        rx_bits = double(real(rx_symbols) > 0);

    case 'QPSK_GRAY'
        % Scaled back from normalized space
        r_y = real(rx_symbols);
        i_y = imag(rx_symbols);
        
        % Constellation points (Figure 2):
        % 01 -> (-1, +1), 11 -> (+1, +1), 00 -> (-1, -1), 10 -> (+1, -1)
        % Notice:
        % b0 (first bit) is 1 if Real > 0, 0 if Real < 0
        % b1 (second bit) is 1 if Imag > 0, 0 if Imag < 0
        b0 = double(r_y > 0);
        b1 = double(i_y > 0);
        
        bits_matrix = [b0, b1];
        rx_bits = reshape(bits_matrix.', [], 1);

    case 'QPSK_NONGRAY'
        % Constellation points (Figure 3):
        % 00 -> (-1, -1) [Quadrant III]
        % 01 -> (-1, +1) [Quadrant II]
        % 10 -> (+1, +1) [Quadrant I]
        % 11 -> (+1, -1) [Quadrant IV]
        norm_factor = 1 / sqrt(2);
        const_pts = [(-1 - 1j); (-1 + 1j); (1 + 1j); (1 - 1j)] * norm_factor;
        bit_table = [0 0; 0 1; 1 0; 1 1];
        
        % Minimum Euclidean distance
        % Dist matrix: N x 4
        dist2 = abs(rx_symbols - const_pts.').^2;
        [~, min_idx] = min(dist2, [], 2);
        
        dec_bits = bit_table(min_idx, :);
        rx_bits = reshape(dec_bits.', [], 1);

    case '8PSK'
        % 8 constellation points (Figure 2):
        sym_by_int = zeros(8, 1);
        sym_by_int(0 + 1) = exp(1j * 0);
        sym_by_int(1 + 1) = exp(1j * pi / 4);
        sym_by_int(2 + 1) = exp(1j * 3 * pi / 4);
        sym_by_int(3 + 1) = exp(1j * pi / 2);
        sym_by_int(4 + 1) = exp(1j * 7 * pi / 4);
        sym_by_int(5 + 1) = exp(1j * 3 * pi / 2);
        sym_by_int(6 + 1) = exp(1j * pi);
        sym_by_int(7 + 1) = exp(1j * 5 * pi / 4);
        
        bit_table = [
            0 0 0; 0 0 1; 0 1 0; 0 1 1;
            1 0 0; 1 0 1; 1 1 0; 1 1 1
        ];
        
        dist2 = abs(rx_symbols - sym_by_int.').^2;
        [~, min_idx] = min(dist2, [], 2);
        
        dec_bits = bit_table(min_idx, :);
        rx_bits = reshape(dec_bits.', [], 1);

    case '16QAM'
        % Un-normalize received symbols
        norm_factor = 1 / sqrt(10);
        unnorm_rx = rx_symbols / norm_factor;
        
        r_y = real(unnorm_rx);
        i_y = imag(unnorm_rx);
        
        % Quantize to PAM-4 levels: {-3, -1, +1, +3}
        % Decision thresholds at: -2, 0, +2
        demap_pam4 = @(val) ...
            [double(val >= 0), double(abs(val) < 2)]; 
            % val < -2 : b = [0, 0] (-3)
            % -2 <= val < 0 : b = [0, 1] (-1)
            % 0 <= val < 2  : b = [1, 1] (+1)
            % val >= 2      : b = [1, 0] (+3)
            
        b_I = demap_pam4(r_y);
        b_Q = demap_pam4(i_y);
        
        bits_matrix = [b_I, b_Q];
        rx_bits = reshape(bits_matrix.', [], 1);

    otherwise
        error('Unsupported modulation scheme: %s', mod_type);
end

end
