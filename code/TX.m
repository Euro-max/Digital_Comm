%% Multi-Scheme Passband Transmitter (BPSK, QPSK, 16-QAM)
% Controlled via variable: mod_scheme = 'BPSK', 'QPSK', or '16QAM'
% clear; clc; close all;

% Default modulation scheme if run standalone
if ~exist('mod_scheme', 'var')
    mod_scheme = 'BPSK';
end
mod_key = upper(strrep(mod_scheme, '-', ''));

% 1. System & Timing Parameters
N = 100000;             % Target number of bits to transmit
Ts = 1e-3;              % Symbol duration (1 ms)
fc = 10 / Ts;           % Carrier frequency (integer multiple of 1/Ts)
fs = 20 * fc;           % Sampling frequency (20 samples per carrier cycle)
ts = 1 / fs;            % Sampling period

% Time vector for a single symbol duration [0, Ts)
t_sym = 0 : ts : Ts - ts;
L = length(t_sym);      % Number of samples per symbol

% Determine bits per symbol (k) and constellation parameters
switch mod_key
    case 'BPSK'
        k = 1;
        ref_const = [-1, 1];
    case 'QPSK'
        k = 2;
        ref_const = [-1-1i, -1+1i, 1-1i, 1+1i];
    case '16QAM'
        k = 4;
        levels = [-3, -1, 1, 3];
        [I_g, Q_g] = meshgrid(levels, levels);
        ref_const = (I_g(:) + 1i * Q_g(:)).';
    otherwise
        error('Unsupported mod_scheme "%s". Use ''BPSK'', ''QPSK'', or ''16QAM''.', mod_scheme);
end

% Ensure N is an integer multiple of k
N = floor(N / k) * k;
N_sym = N / k;          % Number of transmitted symbols

% Compute average symbol energy (Es) and bit energy (Eb) from constellation
Es = mean(abs(ref_const).^2);
Eb = Es / k;            % BPSK: 1, QPSK: 1, 16-QAM: 2.5

% 2. Generate Binary Data: b_k in {0, 1}
b_k = randi([0, 1], 1, N);

% 3. Symbol Mapper (Exact Constellations from Lab Diagram)
switch mod_key
    case 'BPSK'
        % 0 -> -1, 1 -> +1
        x_k = 2 * b_k - 1;
        
    case 'QPSK'
        % b0 -> I (-1 for 0, +1 for 1), b1 -> Q (-1 for 0, +1 for 1)
        bits_mat = reshape(b_k, 2, []);
        I_k = 2 * bits_mat(1, :) - 1;
        Q_k = 2 * bits_mat(2, :) - 1;
        x_k = I_k + 1i * Q_k;
        
    case '16QAM'
        % Gray map for both I (b0 b1) and Q (b2 b3):
        % 00 -> -3, 01 -> -1, 11 -> +1, 10 -> +3
        bits_mat = reshape(b_k, 4, []);
        b0 = bits_mat(1, :);  b1 = bits_mat(2, :);
        b2 = bits_mat(3, :);  b3 = bits_mat(4, :);
        I_k = (2 * b0 - 1) .* (3 - 2 * b1);
        Q_k = (2 * b2 - 1) .* (3 - 2 * b3);
        x_k = I_k + 1i * Q_k;
end

% --- Complex Column Vector for comm.ConstellationDiagram ---
tx_const = complex(x_k(:));

% Upsample baseband symbols to match the sampling rate (Rectangular pulse shaping)
x_t = repelem(x_k, L);

% 4. Basis Function / Carrier Generation: phi(t)
t_total = 0 : ts : (N_sym * Ts) - ts;
phi_t = sqrt(2 / Ts) * cos(2 * pi * fc * t_total);

% 5. Modulator (Multiplier): s(t) = x(t) * phi(t)
s_t = x_t .* phi_t;