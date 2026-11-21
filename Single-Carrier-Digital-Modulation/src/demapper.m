function [rx_bits, decided_symbols] = demapper(rx_symbols, constellation, k)
% DEMAPPER Decodes noisy baseband symbols back into bits using Minimum
% Euclidean Distance (Maximum Likelihood detection in AWGN).
%
% Inputs:
%   rx_symbols    - Vector of received noisy complex baseband symbols
%   constellation - Lookup table of M reference constellation points
%                   (returned directly by mapper.m)
%   k             - Number of bits per symbol (log2(M))
%
% Outputs:
%   rx_bits         - Row vector of recovered binary bits (0s and 1s)
%   decided_symbols - Row vector of closest constellation symbols chosen

    % 1. Force rx_symbols to a column vector (N x 1) and constellation to a row vector (1 x M)
    rx_col    = rx_symbols(:);
    const_row = constellation(:).';

    % 2. Compute squared Euclidean distance from every received symbol to every constellation point
    % Implicit expansion creates an N x M matrix of differences
    diff_mat = rx_col - const_row;
    dist_sq  = real(diff_mat).^2 + imag(diff_mat).^2;

    % 3. Find the index (1 to M) of the closest constellation point for each symbol
    [~, min_idx] = min(dist_sq, [], 2);

    % 4. Record the decided constellation symbols (optional output)
    decided_symbols = const_row(min_idx);

    % 5. Convert 1-based symbol indices back to 0-based decimal values (0 to M-1)
    dec_values = min_idx - 1;

% 6. Convert each decimal value back to k binary bits (MSB first: b0 b1 ... b_{k-1})
    bit_matrix = zeros(length(dec_values), k);
    for b = 1:k
        bit_matrix(:, b) = bitget(dec_values, k - b + 1);
    end

    % 7. Flatten the N x k bit matrix back into a single row vector of bits
    rx_bits = reshape(bit_matrix.', 1, []);
end