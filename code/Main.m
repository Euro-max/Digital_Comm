%% Main BER Simulation (Combining TX, rayleigh_channel, and RX)
clear; clc; close all;

% === SELECT MODULATION SCHEME HERE ===
mod_scheme = '16QAM';                % Options: 'BPSK', 'QPSK', '16QAM'
mod_key = upper(strrep(mod_scheme, '-', ''));

% 1. Simulation Parameters
Eb_N0_dB = 0 : 2 : 30;               % Eb/N0 range in dB
Eb_N0_lin = 10.^(Eb_N0_dB / 10);     % Linear Eb/N0
BER_sim = zeros(size(Eb_N0_dB));

fprintf('--- Running %s over Rayleigh Flat Fading Channel ---\n', mod_scheme);

% 2. Run Monte Carlo Loop over Eb/N0
for idx = 1:length(Eb_N0_dB)
    
    % --- Step A: Transmitter ---
    TX;
    
    % Calculate Noise PSD (N0) for the current Eb/N0 point
    N0 = Eb / Eb_N0_lin(idx);
    
    % --- Step B: Rayleigh Flat Fading Channel ---
    rayleigh_channel;
    
    % --- Step C: Receiver ---
    RX;
    
    % --- Step D: Count Bit Errors & Compute BER ---
    num_errors = sum(b_k ~= b_hat);
    BER_sim(idx) = num_errors / N;
    
    fprintf('Eb/N0 = %2d dB | Errors = %5d / %d | BER = %.5f\n', ...
            Eb_N0_dB(idx), num_errors, N, BER_sim(idx));
end

% 3. Exact Theoretical Rayleigh Fading BER for Selected Scheme
switch mod_key
    case {'BPSK', 'QPSK'}
        BER_theory = 0.5 * (1 - sqrt(Eb_N0_lin ./ (1 + Eb_N0_lin)));
        
    case '16QAM'
        % Exact Gray-coded 16-QAM BER over Rayleigh fading
        g1 = (2/5)  * Eb_N0_lin;
        g3 = (18/5) * Eb_N0_lin;
        g5 = 10     * Eb_N0_lin;
        BER_theory = (3/8) * (1 - sqrt(g1 ./ (1 + g1))) ...
                   + (1/4) * (1 - sqrt(g3 ./ (1 + g3))) ...
                   - (1/8) * (1 - sqrt(g5 ./ (1 + g5)));
end

% 4. Plot BER vs. Eb/N0
figure('Name', sprintf('BER Performance of %s over Rayleigh Channel', mod_scheme));
semilogy(Eb_N0_dB, BER_sim, 'bo-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
hold on;
semilogy(Eb_N0_dB, BER_theory, 'r--', 'LineWidth', 2);
grid on;
ylim([1e-4, 1]);
xlabel('E_b / N_0 (dB)');
ylabel('Bit Error Rate (BER)');
title(sprintf('%s BER Performance over Rayleigh Flat Fading Channel', mod_scheme));
legend(sprintf('Simulated %s (Passband)', mod_scheme), ...
       sprintf('Theoretical Rayleigh %s', mod_scheme), ...
       'Location', 'southwest');