%% Multi-Scheme Receiver (Passband Implementation with Channel Inversion)
% Expects mod_scheme, r_t, h_upsampled, phi_t, L, N_sym, ts, and N0 in workspace

if ~exist('mod_scheme', 'var')
    mod_scheme = 'BPSK';
end
mod_key = upper(strrep(mod_scheme, '-', ''));

% 1. Generate Passband AWGN: n(t)
% Sampled variance = (N0/2) / ts so post-correlator variance is N0/2 per dimension
sigma_n = sqrt((N0 / 2) / ts);
n_c = sigma_n * randn(1, length(r_t));
n_s = sigma_n * randn(1, length(r_t));
n_t = n_c + 1i * n_s;

% 2. Add Noise at Receiver Input: y(t) = r(t) + n(t)
y_t = r_t + n_t;

% 3. Channel Inversion: divide out the complex fading coefficient h(t)
y_inv = y_t ./ h_upsampled;

% 4. Complex Correlator Outputs (Before & After Channel Inversion)
% Multiply by phi(t) and integrate over each symbol duration [0, Ts]
rx_before_inv = sum(reshape(y_t .* phi_t, L, N_sym), 1) * ts;
rx_after_inv  = sum(reshape(y_inv .* phi_t, L, N_sym), 1) * ts;

% Extract Equalized In-Phase (I) and Quadrature (Q) components
I_hat = real(rx_after_inv);
Q_hat = imag(rx_after_inv);

% 5. Decision Device (Matched to Exact Lab Constellations)
switch mod_key
    case 'BPSK'
        % Threshold = 0 -> 1 if I >= 0, else 0
        b_hat = double(I_hat >= 0);
        
    case 'QPSK'
        % Threshold = 0 on both I (b0) and Q (b1)
        b0_hat = double(I_hat >= 0);
        b1_hat = double(Q_hat >= 0);
        b_hat  = reshape([b0_hat; b1_hat], 1, []);
        
    case '16QAM'
        % Gray decision boundaries at -2, 0, +2 on both I (b0 b1) and Q (b2 b3):
        % MSB (b0, b2): 1 if >= 0, 0 if < 0
        % LSB (b1, b3): 1 if inner level (|val| < 2), 0 if outer level (|val| >= 2)
        b0_hat = double(I_hat >= 0);
        b1_hat = double(abs(I_hat) < 2);
        b2_hat = double(Q_hat >= 0);
        b3_hat = double(abs(Q_hat) < 2);
        b_hat  = reshape([b0_hat; b1_hat; b2_hat; b3_hat], 1, []);
        
    otherwise
        error('Unsupported mod_scheme "%s". Use ''BPSK'', ''QPSK'', or ''16QAM''.', mod_scheme);
end