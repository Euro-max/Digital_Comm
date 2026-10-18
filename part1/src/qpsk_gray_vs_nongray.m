% QPSK_GRAY_VS_NONGRAY
% Task 2: Comparative BER Analysis between Gray and Non-Gray QPSK
%
% Compares:
%   - Figure 2: Gray-coded QPSK
%   - Figure 3: Non-Gray coded QPSK
%
% Cairo University - Faculty of Engineering
% Electronics and Communications Dept. - 3rd Year Digital Communications

clear; clc; close all;

%% Simulation Parameters
EbNo_dB = 0:1:12;                         % Eb/N0 range in dB
target_errors = 300;                      % Target bit errors
max_bits = 4e6;                           % Max bits per SNR
min_bits = 4e5;                           % Min bits per SNR
k = 2;                                    % Bits per symbol for QPSK

schemes = {'QPSK_Gray', 'QPSK_NonGray'};
labels = {'QPSK Figure 2 (Gray Coded)', 'QPSK Figure 3 (Non-Gray Coded)'};
colors = {'#1f77b4', '#d62728'};
markers = {'o', 's'};

ber_sim = zeros(2, length(EbNo_dB));

fprintf('===============================================================\n');
fprintf('  Task 2: QPSK Gray vs. Non-Gray Mapping BER Comparison       \n');
fprintf('===============================================================\n');

%% Simulation Loop
for s = 1:2
    mod_type = schemes{s};
    fprintf('\n---> Simulating %s...\n', labels{s});
    
    for i = 1:length(EbNo_dB)
        snr_db = EbNo_dB(i);
        tot_bits = 0;
        tot_errors = 0;
        
        while (tot_errors < target_errors) && (tot_bits < max_bits)
            batch_symbols = 50000;
            batch_bits = batch_symbols * k;
            
            % Generate random bits
            tx_bits = randi([0 1], batch_bits, 1);
            
            % Map to symbols
            [tx_symbols, ~] = mapper(tx_bits, mod_type);
            
            % Channel corruption (AWGN)
            rx_symbols = awgn_channel(tx_symbols, snr_db, k, true);
            
            % Demap
            rx_bits = demapper(rx_symbols, mod_type);
            
            % Count bit errors
            errors = sum(tx_bits ~= rx_bits);
            tot_errors = tot_errors + errors;
            tot_bits = tot_bits + batch_bits;
            
            if (tot_bits >= min_bits) && (tot_errors == 0)
                break;
            end
        end
        
        ber_sim(s, i) = tot_errors / tot_bits;
        fprintf('   Eb/N0 = %2d dB | Bits = %7d | Errors = %5d | BER = %.3e\n', ...
            snr_db, tot_bits, tot_errors, ber_sim(s, i));
    end
end

% Theoretical curve for Gray-coded QPSK
ber_theo = theoretical_ber(EbNo_dB, 'QPSK');

%% Plotting
figure('Name', 'Task 2 - QPSK Gray vs Non-Gray', 'Position', [150 150 850 600]);

% Theoretical curve
semilogy(EbNo_dB, ber_theo, 'k--', 'LineWidth', 1.8, ...
    'DisplayName', 'QPSK Theoretical (Gray: Q(\surd(2E_b/N_0)))');
hold on;

% Gray simulation
idx1 = ber_sim(1, :) > 0;
semilogy(EbNo_dB(idx1), ber_sim(1, idx1), 'o-', 'Color', colors{1}, ...
    'LineWidth', 1.6, 'MarkerSize', 7, 'DisplayName', labels{1});

% Non-Gray simulation
idx2 = ber_sim(2, :) > 0;
semilogy(EbNo_dB(idx2), ber_sim(2, idx2), 's-', 'Color', colors{2}, ...
    'LineWidth', 1.6, 'MarkerSize', 7, 'DisplayName', labels{2});

grid on;
box on;
xlabel('E_b / N_0 (dB)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontSize', 12, 'FontWeight', 'bold');
title('Effect of Bit Mapping on QPSK Performance over AWGN Channel', ...
    'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'southwest', 'FontSize', 10);
axis([0 12 1e-6 1]);

% Save plot to results folder
output_dir = fullfile('..', 'results');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

savefig(fullfile(output_dir, 'task2_qpsk_comparison.fig'));
saveas(gcf, fullfile(output_dir, 'task2_qpsk_comparison.png'));
fprintf('\n[SUCCESS] Task 2 plot saved to %s\n', fullfile(output_dir, 'task2_qpsk_comparison.png'));
