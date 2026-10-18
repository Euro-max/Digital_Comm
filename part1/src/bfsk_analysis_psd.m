% BFSK_ANALYSIS_PSD
% Task 3: BFSK Performance, Signal Analysis, and Baseband PSD Simulation
%
% Tasks:
%   1. Coherent BFSK BER vs. Eb/N0 over AWGN (Simulated vs. Theoretical)
%   2. Simulation of Power Spectral Density (PSD) using the baseband equivalent signal
%
% Cairo University - Faculty of Engineering
% Electronics and Communications Dept. - 3rd Year Digital Communications

clear; clc; close all;

%% =========================================================================
%% Section 1: Coherent BFSK BER Simulation
%% =========================================================================
fprintf('===============================================================\n');
fprintf('  Task 3: BFSK BER Simulation & Baseband PSD Analysis          \n');
fprintf('===============================================================\n');

EbNo_dB = 0:1:13;
target_errors = 300;
max_bits = 4e6;
min_bits = 4e5;

ber_sim = zeros(size(EbNo_dB));
ber_theo = theoretical_ber(EbNo_dB, 'BFSK'); % Q(sqrt(Eb/N0))

fprintf('\n---> Running BFSK BER Monte Carlo Simulation...\n');

for i = 1:length(EbNo_dB)
    snr_db = EbNo_dB(i);
    tot_bits = 0;
    tot_errors = 0;
    
    EbNo_lin = 10^(snr_db / 10);
    N0 = 1 / EbNo_lin;               % Assuming Eb = 1
    sigma = sqrt(N0 / 2);
    
    while (tot_errors < target_errors) && (tot_bits < max_bits)
        batch_bits = 100000;
        tx_bits = randi([0 1], batch_bits, 1);
        
        % Signal space representation for orthogonal BFSK:
        % Bit 0 -> s0 = [sqrt(Eb), 0]
        % Bit 1 -> s1 = [0, sqrt(Eb)]
        r1 = (tx_bits == 0) * 1.0 + sigma * randn(batch_bits, 1);
        r2 = (tx_bits == 1) * 1.0 + sigma * randn(batch_bits, 1);
        
        % Optimum ML decision rule: r2 > r1 -> decided bit 1, else 0
        rx_bits = double(r2 > r1);
        
        errors = sum(tx_bits ~= rx_bits);
        tot_errors = tot_errors + errors;
        tot_bits = tot_bits + batch_bits;
        
        if (tot_bits >= min_bits) && (tot_errors == 0)
            break;
        end
    end
    
    ber_sim(i) = tot_errors / tot_bits;
    fprintf('   Eb/N0 = %2d dB | Bits = %7d | Errors = %5d | BER = %.3e\n', ...
        snr_db, tot_bits, tot_errors, ber_sim(i));
end

%% Plot BFSK BER Curve
figure('Name', 'Task 3 - BFSK BER Curve', 'Position', [100 100 800 550]);
semilogy(EbNo_dB, ber_theo, 'r-', 'LineWidth', 1.8, 'DisplayName', 'Theoretical: Q(\surd(E_b/N_0))');
hold on;
idx = ber_sim > 0;
semilogy(EbNo_dB(idx), ber_sim(idx), 'bo', 'LineWidth', 1.5, 'MarkerSize', 7, ...
    'DisplayName', 'Simulated BFSK (Coherent)');
grid on; box on;
xlabel('E_b / N_0 (dB)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontSize', 12, 'FontWeight', 'bold');
title('Coherent BFSK BER vs. E_b/N_0 over AWGN Channel', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'southwest', 'FontSize', 11);
axis([0 13 1e-6 1]);

%% =========================================================================
%% Section 2: BFSK Baseband Equivalent Signal & PSD Simulation
%% =========================================================================
fprintf('\n---> Simulating BFSK Baseband Equivalent Power Spectral Density (PSD)...\n');

% Parameters for continuous-time baseband waveform synthesis
Tb = 1e-3;                 % Bit duration = 1 ms (Rb = 1 kHz)
samples_per_bit = 32;      % Oversampling factor
Fs = samples_per_bit / Tb; % Sampling frequency (32 kHz)
dt = 1 / Fs;

% Carrier choice: fc = (f1 + f2)/2 -> frequency shift is +/- Delta_f / 2 = +/- 1 / (2*Tb)
% Delta_f = 1/Tb for orthogonal BFSK
Delta_f = 1 / Tb;
f_dev = Delta_f / 2;       % 500 Hz

N_symbols = 20000;
bits = randi([0 1], N_symbols, 1);

% Baseband equivalent complex pulse for each bit:
% For bit 0: exp(-j * 2*pi * f_dev * t)
% For bit 1: exp(+j * 2*pi * f_dev * t)
t_bit = (0:samples_per_bit-1)' * dt;
pulse0 = exp(-1j * 2 * pi * f_dev * t_bit);
pulse1 = exp(+1j * 2 * pi * f_dev * t_bit);

% Assemble full baseband equivalent waveform
signal_matrix = zeros(samples_per_bit, N_symbols);
for n = 1:N_symbols
    if bits(n) == 0
        signal_matrix(:, n) = pulse0;
    else
        signal_matrix(:, n) = pulse1;
    end
end
baseband_signal = signal_matrix(:);

% Compute Welch PSD estimate
nfft = 2048;
window = hamming(1024);
noverlap = 512;
[Pxx, f] = pwelch(baseband_signal, window, noverlap, nfft, Fs, 'centered');

%% Plot BFSK Baseband PSD
figure('Name', 'Task 3 - BFSK Baseband PSD', 'Position', [150 150 850 550]);
plot(f / 1e3, 10*log10(Pxx / max(Pxx)), 'b-', 'LineWidth', 1.6);
grid on; box on;
xlabel('Frequency (kHz) [Relative to Carrier f_c]', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Normalized Power Spectral Density (dB/Hz)', 'FontSize', 12, 'FontWeight', 'bold');
title('Simulated Power Spectral Density of Baseband Equivalent BFSK Signal', ...
    'FontSize', 13, 'FontWeight', 'bold');
xlim([-4*Delta_f/1e3, 4*Delta_f/1e3]);
ylim([-50 5]);

%% Save All Results
output_dir = fullfile('..', 'results');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

saveas(1, fullfile(output_dir, 'task3_bfsk_ber.png'));
savefig(1, fullfile(output_dir, 'task3_bfsk_ber.fig'));
saveas(2, fullfile(output_dir, 'task3_bfsk_psd.png'));
savefig(2, fullfile(output_dir, 'task3_bfsk_psd.fig'));

fprintf('\n[SUCCESS] Task 3 plots saved to %s\n', output_dir);
