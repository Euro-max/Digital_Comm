% MAIN_MODULATION_BER
% Simulation of Single Carrier Baseband System under AWGN Channel
% Task 1: BER vs. Eb/N0 for BPSK, QPSK, 8PSK, and 16-QAM
%
% Cairo University - Faculty of Engineering
% Electronics and Communications Dept. - 3rd Year Digital Communications

clear; clc; close all;

%% Simulation Parameters
EbNo_dB = 0:1:14;                         % Eb/N0 range in dB
target_errors = 200;                      % Minimum bit errors for confidence
max_bits = 3e6;                           % Maximum bits simulated per point
min_bits = 3e5;                           % Minimum bits simulated per point

schemes = {'BPSK', 'QPSK_Gray', '8PSK', '16QAM'};
scheme_labels = {'BPSK', 'QPSK (Gray)', '8-PSK', '16-QAM'};
colors = {'#1f77b4', '#ff7f0e', '#2ca02c', '#d62728'};
markers = {'o', 's', '^', 'd'};

ber_sim = zeros(length(schemes), length(EbNo_dB));
ber_theo = zeros(length(schemes), length(EbNo_dB));

fprintf('===============================================================\n');
fprintf('  Single Carrier Modulation BER Simulation under AWGN Channel  \n');
fprintf('===============================================================\n');

%% Simulation Loop
for s = 1:length(schemes)
    mod_type = schemes{s};
    fprintf('\n---> Simulating %s...\n', scheme_labels{s});
    
    switch upper(mod_type)
        case 'BPSK',       k = 1; is_complex = false;
        case 'QPSK_GRAY',  k = 2; is_complex = true;
        case '8PSK',       k = 3; is_complex = true;
        case '16QAM',      k = 4; is_complex = true;
    end
    
    % Theoretical BER calculation
    ber_theo(s, :) = theoretical_ber(EbNo_dB, mod_type);
    
    for i = 1:length(EbNo_dB)
        snr_db = EbNo_dB(i);
        tot_bits = 0;
        tot_errors = 0;
        
        while (tot_errors < target_errors) && (tot_bits < max_bits)
            batch_symbols = 50000;
            batch_bits = batch_symbols * k;
            
            % 1. Transmitter: Generate bits and map to symbols
            tx_bits = randi([0 1], batch_bits, 1);
            [tx_symbols, ~] = mapper(tx_bits, mod_type);
            
            % 2. Channel: Add AWGN using randn
            rx_symbols = awgn_channel(tx_symbols, snr_db, k, is_complex);
            
            % 3. Receiver: Demap symbols to bits
            rx_bits = demapper(rx_symbols, mod_type);
            
            % 4. BER Calculation
            errors = sum(tx_bits ~= rx_bits);
            tot_errors = tot_errors + errors;
            tot_bits = tot_bits + batch_bits;
            
            % Break early if SNR is high and zero errors occurred over min_bits
            if (tot_bits >= min_bits) && (tot_errors == 0)
                break;
            end
        end
        
        ber_sim(s, i) = tot_errors / tot_bits;
        fprintf('   Eb/N0 = %2d dB | Bits = %7d | Errors = %5d | BER = %.3e\n', ...
            snr_db, tot_bits, tot_errors, ber_sim(s, i));
    end
end

%% Plotting Results
figure('Name', 'Task 1 - Multi-Modulation BER Comparison', 'Position', [100 100 900 650]);

for s = 1:length(schemes)
    % Plot Theoretical Curve
    semilogy(EbNo_dB, ber_theo(s, :), '-', 'Color', colors{s}, 'LineWidth', 1.8, ...
        'DisplayName', sprintf('%s (Theoretical)', scheme_labels{s}));
    hold on;
    
    % Plot Simulated Points
    sim_idx = ber_sim(s, :) > 0;
    semilogy(EbNo_dB(sim_idx), ber_sim(s, sim_idx), markers{s}, 'Color', colors{s}, ...
        'MarkerSize', 7, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%s (Simulated)', scheme_labels{s}));
end

grid on;
box on;
xlabel('E_b / N_0 (dB)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontSize', 12, 'FontWeight', 'bold');
title('BER vs. E_b/N_0 for Digital Modulation Schemes over AWGN Channel', ...
    'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'southwest', 'FontSize', 10);
axis([0 14 1e-6 1]);

% Save plot to results folder
output_dir = fullfile('..', 'results');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

savefig(fullfile(output_dir, 'task1_ber_comparison.fig'));
saveas(gcf, fullfile(output_dir, 'task1_ber_comparison.png'));
fprintf('\n[SUCCESS] Task 1 plot saved to %s\n', fullfile(output_dir, 'task1_ber_comparison.png'));
