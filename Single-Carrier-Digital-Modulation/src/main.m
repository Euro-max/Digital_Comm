%% Digital Communications Project - Part 1
% General Master Simulation Script
% Runs all Part 1 simulations, saves all results to 'all_results_part1.mat',
% and calls plots.m to generate all tables and figures.
%
% Dependencies:
%   mapper.m, awgn_channel.m, demapper.m, theoretical_ber.m,
%   qpsk_gray_vs_nongray.m, bfsk_analysis_psd.m, plots.m

clc; clear; close all;

%% 1. Global Simulation Parameters
params.seed           = 42;                % Fixed seed for reproducibility
params.num_bits       = 1.2e6;             % Divisible by lcm(1,2,3,4) = 12
params.EbNo_dB        = -2 : 1 : 15;       % Covers 5 dB & 15 dB snapshots + 1e-4 crossing
params.EbNo_fine      = linspace(min(params.EbNo_dB), max(params.EbNo_dB), 300);
params.snap_snrs_dB   = [5, 15];           % Checklist #5: noisy constellations
params.snapshot_count = 3000;              % Symbols saved per constellation plot

% BFSK PSD & waveform parameters
params.num_bits_psd   = 2e4;               % Bits used for smooth Welch PSD
params.Tb             = 1;                 % Normalized bit duration (s)
params.sps            = 16;                % Samples per bit

rng(params.seed);

%% 2. Section 1.4: Single-Carrier AWGN BER (BPSK, QPSK, 8PSK, 16-QAM)
schemes     = {'BPSK', 'QPSK', '8PSK', '16QAM'};
num_schemes = length(schemes);
num_snr     = length(params.EbNo_dB);

part1.schemes        = schemes;
part1.k_values       = zeros(1, num_schemes);
part1.sim_ber        = zeros(num_schemes, num_snr);
part1.theo_ber       = zeros(num_schemes, num_snr);
part1.theo_ber_fine  = zeros(num_schemes, length(params.EbNo_fine));
part1.constellations = cell(1, num_schemes);
part1.rx_snap_5dB    = cell(1, num_schemes);
part1.rx_snap_15dB   = cell(1, num_schemes);

fprintf('=== Part 1 Digital Communications Simulation ===\n');
fprintf('[1/3] Running BPSK, QPSK, 8PSK, 16-QAM (%d bits/point)...\n', params.num_bits);

for m = 1:num_schemes
    mod_name = schemes{m};
    fprintf('      Simulating %-5s ... ', mod_name);

    part1.theo_ber(m, :)      = theoretical_ber(params.EbNo_dB,   mod_name);
    part1.theo_ber_fine(m, :) = theoretical_ber(params.EbNo_fine, mod_name);

    for s = 1:num_snr
        tx_bits = randi([0 1], 1, params.num_bits);
        [tx_sym, k, const] = mapper(tx_bits, mod_name);
        rx_sym  = awgn_channel(tx_sym, params.EbNo_dB(s), k);
        rx_bits = demapper(rx_sym, const, k);

        part1.sim_ber(m, s) = mean(tx_bits ~= rx_bits);

        % Save constellation & noisy snapshots at 5 dB and 15 dB
        if params.EbNo_dB(s) == params.snap_snrs_dB(1)
            part1.k_values(m)       = k;
            part1.constellations{m} = const;
            part1.rx_snap_5dB{m}    = rx_sym(1:min(params.snapshot_count, end));
        elseif params.EbNo_dB(s) == params.snap_snrs_dB(2)
            part1.rx_snap_15dB{m}   = rx_sym(1:min(params.snapshot_count, end));
        end
    end
    fprintf('Done.\n');
end

%% 3. Section 1.4: QPSK Gray (Fig. 2) vs. Non-Gray (Fig. 3)
fprintf('[2/3] Running QPSK Gray vs. Non-Gray comparison ... ');
qpsk = qpsk_gray_vs_nongray(params.num_bits, params.EbNo_dB, params.EbNo_fine, params.seed);
fprintf('Done.\n');

%% 4. Section 1.5: BFSK BER, Baseband Welch PSD, and Time-Domain Waveform
fprintf('[3/3] Running BFSK BER & Baseband PSD analysis ... ');
bfsk = bfsk_analysis_psd(params.num_bits, params.EbNo_dB, params.EbNo_fine, ...
                         params.num_bits_psd, params.Tb, params.sps, params.seed);
fprintf('Done.\n');

%% 5. Save All Results & Launch Master Plotting Script
save('all_results_part1.mat', 'params', 'part1', 'qpsk', 'bfsk');
fprintf('\nAll simulations complete. Saved to all_results_part1.mat\n\n');

plots;