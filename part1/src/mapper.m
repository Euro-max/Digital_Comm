function [symbols, const_map] = mapper(bits, mod_type)
% MAPPER Maps input binary stream to baseband complex symbols.
%
%   [symbols, const_map] = MAPPER(bits, mod_type)
%
%   Inputs:
%       bits     - Row or column vector of binary values (0 or 1)
%       mod_type - 'BPSK', 'QPSK_Gray', 'QPSK_NonGray', '8PSK', '16QAM'
%
%   Outputs:
%       symbols   - Vector of complex baseband symbols
%       const_map - Struct containing constellation points and bit mappings
%
%   Modulation Mappings match Project Part 1 Specifications (Figure 2 & 3).

bits = bits(:); % Ensure column vector

switch upper(mod_type)
    case 'BPSK'
        % BPSK: b0 = 0 -> -1, b0 = 1 -> +1
        % Normalized Eb = 1
        bit_table = [0; 1];
        sym_table = [-1; 1];
        k = 1;
        
        symbols = sym_table(bits + 1);

    case 'QPSK_GRAY'
        % Figure 2 QPSK:
        % 01 -> -1 + 1j
        % 11 ->  1 + 1j
        % 00 -> -1 - 1j
        % 10 ->  1 - 1j
        k = 2;
        % Pad bits if needed
        rem_bits = mod(length(bits), k);
        if rem_bits ~= 0
            bits = [bits; zeros(k - rem_bits, 1)];
        end
        
        bit_table = [0 0; 0 1; 1 0; 1 1];
        sym_raw   = [(-1 - 1j); (-1 + 1j); (1 - 1j); (1 + 1j)];
        norm_factor = 1 / sqrt(2); % Normalize so average Es = 1, Eb = 0.5
        sym_table = sym_raw * norm_factor;
        
        bit_matrix = reshape(bits, k, []).';
        idx = bit_matrix * [2; 1] + 1; % Binary to integer (00->1, 01->2, 10->3, 11->4)
        symbols = sym_table(idx);

    case 'QPSK_NONGRAY'
        % Figure 3 QPSK (Non-Gray):
        % 01 -> -1 + 1j
        % 10 ->  1 + 1j  (Differs by 2 bits from 01!)
        % 00 -> -1 - 1j
        % 11 ->  1 - 1j
        k = 2;
        rem_bits = mod(length(bits), k);
        if rem_bits ~= 0
            bits = [bits; zeros(k - rem_bits, 1)];
        end
        
        % Mapping according to Figure 3:
        % 00 -> -1 - 1j (idx 1)
        % 01 -> -1 + 1j (idx 2)
        % 10 ->  1 + 1j (idx 3)
        % 11 ->  1 - 1j (idx 4)
        sym_raw   = [(-1 - 1j); (-1 + 1j); (1 + 1j); (1 - 1j)];
        norm_factor = 1 / sqrt(2);
        sym_table = sym_raw * norm_factor;
        
        bit_matrix = reshape(bits, k, []).';
        idx = bit_matrix * [2; 1] + 1;
        symbols = sym_table(idx);

    case '8PSK'
        % Figure 2 8PSK (Gray coded on unit circle):
        % 000 -> ( 1,  0)
        % 001 -> ( c,  s) = exp(j*pi/4)
        % 011 -> ( 0,  1) = exp(j*pi/2)
        % 010 -> (-c,  s) = exp(j*3*pi/4)
        % 110 -> (-1,  0) = exp(j*pi)
        % 111 -> (-c, -s) = exp(j*5*pi/4)
        % 101 -> ( 0, -1) = exp(j*3*pi/2)
        % 100 -> ( c, -s) = exp(j*7*pi/4)
        k = 3;
        rem_bits = mod(length(bits), k);
        if rem_bits ~= 0
            bits = [bits; zeros(k - rem_bits, 1)];
        end
        
        bit_table = [
            0 0 0; % 0 -> exp(j*0)
            0 0 1; % 1 -> exp(j*pi/4)
            0 1 0; % 2 -> exp(j*3*pi/4)
            0 1 1; % 3 -> exp(j*pi/2)
            1 0 0; % 4 -> exp(j*7*pi/4)
            1 0 1; % 5 -> exp(j*3*pi/2)
            1 1 0; % 6 -> exp(j*pi)
            1 1 1  % 7 -> exp(j*5*pi/4)
        ];
        
        % Map integers 0..7 to complex points
        sym_by_int = zeros(8, 1);
        sym_by_int(0 + 1) = exp(1j * 0);
        sym_by_int(1 + 1) = exp(1j * pi / 4);
        sym_by_int(2 + 1) = exp(1j * 3 * pi / 4);
        sym_by_int(3 + 1) = exp(1j * pi / 2);
        sym_by_int(4 + 1) = exp(1j * 7 * pi / 4);
        sym_by_int(5 + 1) = exp(1j * 3 * pi / 2);
        sym_by_int(6 + 1) = exp(1j * pi);
        sym_by_int(7 + 1) = exp(1j * 5 * pi / 4);
        
        bit_matrix = reshape(bits, k, []).';
        idx = bit_matrix * [4; 2; 1] + 1;
        symbols = sym_by_int(idx);
        sym_table = sym_by_int;

    case '16QAM'
        % Figure 2 16-QAM (Gray coded grid on I, Q in {-3, -1, 1, 3}):
        % Grid layout from Fig. 2:
        % Q = +3: [0010, 0110, 1110, 1010] across I = [-3, -1, +1, +3]
        % Q = +1: [0011, 0111, 1111, 1011] across I = [-3, -1, +1, +3]
        % Q = -1: [0001, 0101, 1101, 1001] across I = [-3, -1, +1, +3]
        % Q = -3: [0000, 0100, 1100, 1000] across I = [-3, -1, +1, +3]
        %
        % Decomposing into independent I and Q Gray mapping:
        % b0 b1 determines I:
        % 00 -> -3, 01 -> -1, 11 -> +1, 10 -> +3
        % b2 b3 determines Q:
        % 00 -> -3, 01 -> -1, 11 -> +1, 10 -> +3
        k = 4;
        rem_bits = mod(length(bits), k);
        if rem_bits ~= 0
            bits = [bits; zeros(k - rem_bits, 1)];
        end
        
        bit_matrix = reshape(bits, k, []).';
        b_I = bit_matrix(:, 1:2);
        b_Q = bit_matrix(:, 3:4);
        
        % Gray map for 2 bits: 00->-3, 01->-1, 11->+1, 10->+3
        map_2bit = @(b) (-3)*(b(:,1)==0 & b(:,2)==0) + ...
                        (-1)*(b(:,1)==0 & b(:,2)==1) + ...
                        ( 1)*(b(:,1)==1 & b(:,2)==1) + ...
                        ( 3)*(b(:,1)==1 & b(:,2)==0);
        
        I = map_2bit(b_I);
        Q = map_2bit(b_Q);
        
        % Normalize such that average Es = 1 (sum(I^2+Q^2)/16 = 10 -> scale 1/sqrt(10))
        norm_factor = 1 / sqrt(10);
        symbols = (I + 1j * Q) * norm_factor;
        sym_table = [];

    otherwise
        error('Unsupported modulation scheme: %s', mod_type);
end

const_map.mod_type = mod_type;
const_map.k = k;
if exist('sym_table', 'var')
    const_map.sym_table = sym_table;
end
end
