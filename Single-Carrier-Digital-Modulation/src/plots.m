%% Digital Communications Project - Part 1
% Master Plotting & Reporting Script (All 11 Checklist Items)
% Can be run standalone anytime after main.m generates 'all_results_part1.mat'.

close all;

%% 0. User Options & Data Loading
include_bfsk_in_combined = true;   % Checklist #9 (true = all 5 schemes on fig:ber_all)
export_figs              = false;  % Set true to auto-save 300-DPI PNGs into ./figures/

mat_filename = 'all_results_part1.mat';
if exist(mat_filename, 'file')
    load(mat_filename);
elseif exist(fullfile('..', 'results', mat_filename), 'file')
    load(fullfile('..', 'results', mat_filename));
elseif exist(fullfile('results', mat_filename), 'file')
    load(fullfile('results', mat_filename));
else
    error('all_results_part1.mat not found. Run main.m first.');
end

if export_figs && ~exist('figures', 'dir')
    mkdir('figures');
end

% Consistent colorblind-friendly palette
colors = [0.0000, 0.4470, 0.7410;   % 1: Blue   (BPSK)
          0.8500, 0.3250, 0.0980;   % 2: Orange (QPSK)
          0.4660, 0.6740, 0.1880;   % 3: Green  (8PSK)
          0.4940, 0.1840, 0.5560;   % 4: Purple (16-QAM)
          0.9290, 0.6940, 0.1250];  % 5: Gold   (BFSK)
markers = {'o', 'x', '^', 's', 'd'};
m_sizes = [7.5, 8.5, 7, 7, 7];

%% ========================================================================
%  COMMAND WINDOW TABLES (Checklist #7 & #8 + BER Verification Table)
%  ========================================================================

% --- Checklist #8: Simulation Parameters Table (tab:params) ---
fprintf('======================================================================\n');
fprintf('  TABLE 1: Simulation Parameters (tab:params)\n');
fprintf('======================================================================\n');
fprintf('  Random Seed (rng)         : %d\n', params.seed);
fprintf('  Bits per Eb/N0 point      : %.2e (%d bits)\n', params.num_bits, params.num_bits);
fprintf('  Eb/N0 Sweep Range         : %d dB to %d dB (step %d dB)\n', ...
        min(params.EbNo_dB), max(params.EbNo_dB), params.EbNo_dB(2)-params.EbNo_dB(1));
fprintf('  Constellation Snapshots   : %d dB and %d dB (%d symbols)\n', ...
        params.snap_snrs_dB(1), params.snap_snrs_dB(2), params.snapshot_count);
fprintf('  BFSK PSD Bits / sps / Tb  : %d bits / %d samples/bit / %.1f s\n', ...
        params.num_bits_psd, params.sps, params.Tb);
fprintf('======================================================================\n\n');

% --- Checklist #7: Required Eb/N0 at BER = 1e-4 (tab:req) ---
target_ber = 1e-4;
all_names  = {'BPSK', 'QPSK (Gray)', 'QPSK (Fig. 3)', '8PSK', '16-QAM', 'BFSK'};
sim_list   = {part1.sim_ber(1,:), part1.sim_ber(2,:), qpsk.sim_nongray, ...
              part1.sim_ber(3,:), part1.sim_ber(4,:), bfsk.sim_ber};
theo_list  = {part1.theo_ber_fine(1,:), part1.theo_ber_fine(2,:), qpsk.theo_nongray_fine, ...
              part1.theo_ber_fine(3,:), part1.theo_ber_fine(4,:), bfsk.theo_ber_fine};

fprintf('======================================================================\n');
fprintf('  TABLE 2: Required Eb/N0 (dB) at BER = 1e-4 (tab:req)\n');
fprintf('======================================================================\n');
fprintf('  Modulation Scheme  |  Simulated (dB)  |  Theoretical (dB)  |  Diff\n');
fprintf('  -------------------+------------------+--------------------+--------\n');
for i = 1:length(all_names)
    req_sim  = find_ebno_at_ber(params.EbNo_dB,   sim_list{i},  target_ber);
    req_theo = find_ebno_at_ber(params.EbNo_fine, theo_list{i}, target_ber);
    fprintf('  %-18s |      %6.2f      |       %6.2f       | %+5.2f\n', ...
            all_names{i}, req_sim, req_theo, req_sim - req_theo);
end
fprintf('======================================================================\n\n');

% --- Full BER Verification Summary Table ---
fprintf('===================================================================================\n');
fprintf('  TABLE 3: Simulated / Theoretical BER at Selected Eb/N0 Points\n');
fprintf('===================================================================================\n');
fprintf('Eb/N0 |     BPSK      |     QPSK      |     8PSK      |    16-QAM     |     BFSK\n');
fprintf(' (dB) |  Sim / Theo   |  Sim / Theo   |  Sim / Theo   |  Sim / Theo   |  Sim / Theo\n');
fprintf('------+---------------+---------------+---------------+---------------+-------------\n');
for val = [0, 2, 4, 6, 8, 10, 12]
    idx = find(params.EbNo_dB == val, 1);
    if ~isempty(idx)
        fprintf(' %3d  | %.4f/%.4f | %.4f/%.4f | %.4f/%.4f | %.4f/%.4f | %.4f/%.4f\n', ...
            val, ...
            part1.sim_ber(1,idx), part1.theo_ber(1,idx), ...
            part1.sim_ber(2,idx), part1.theo_ber(2,idx), ...
            part1.sim_ber(3,idx), part1.theo_ber(3,idx), ...
            part1.sim_ber(4,idx), part1.theo_ber(4,idx), ...
            bfsk.sim_ber(idx),    bfsk.theo_ber(idx));
    end
end
fprintf('===================================================================================\n\n');

%% ========================================================================
%  FIGURE 1: Combined BER vs. Eb/N0 (Checklist #1 & #9 -> fig:ber_all)
%  ========================================================================
f1 = figure('Name', 'fig:ber_all - Combined BER vs Eb/N0', ...
            'Color', 'w', 'Position', [60, 80, 960, 620]);
hold on;

for m = 1:4
    semilogy(params.EbNo_fine, part1.theo_ber_fine(m, :), '-', ...
        'Color', colors(m, :), 'LineWidth', 1.8, ...
        'DisplayName', sprintf('%s (Theory)', part1.schemes{m}));
    semilogy(params.EbNo_dB, part1.sim_ber(m, :), markers{m}, ...
        'Color', colors(m, :), 'MarkerSize', m_sizes(m), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%s (Sim)', part1.schemes{m}));
end

if include_bfsk_in_combined
    semilogy(bfsk.EbNo_fine, bfsk.theo_ber_fine, '-', ...
        'Color', colors(5, :), 'LineWidth', 1.8, 'DisplayName', 'BFSK (Theory)');
    semilogy(bfsk.EbNo_dB, bfsk.sim_ber, markers{5}, ...
        'Color', colors(5, :), 'MarkerSize', m_sizes(5), 'LineWidth', 1.5, ...
        'DisplayName', 'BFSK (Sim)');
    fig1_title = 'Baseband AWGN BER Performance: BPSK, QPSK, 8PSK, 16-QAM, and BFSK';
else
    fig1_title = 'Baseband AWGN BER Performance: BPSK, QPSK, 8PSK, and 16-QAM';
end

yline(1e-4, '--', 'BER = 10^{-4}', 'Color', [0.4 0.4 0.4], ...
      'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
set(gca, 'YScale', 'log', 'FontSize', 12, 'LineWidth', 1.1, 'Box', 'on');
grid on; grid minor;
xlim([min(params.EbNo_dB), max(params.EbNo_dB)]);
ylim([1e-5, 1]);
xlabel('$E_b/N_0$ (dB)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Bit Error Rate (BER)', 'Interpreter', 'latex', 'FontSize', 14);
title(fig1_title, 'FontSize', 13.5, 'FontWeight', 'bold');
legend('Location', 'southwest', 'FontSize', 10, 'NumColumns', 2);
hold off;
save_if_enabled(f1, 'ber_all', export_figs);

%% ========================================================================
%  FIGURE 2: QPSK Gray vs. Fig. 3 Non-Gray (Checklist #2 -> fig:qpsk_cmp)
%  ========================================================================
f2 = figure('Name', 'fig:qpsk_cmp - QPSK Gray vs Non-Gray', ...
            'Color', 'w', 'Position', [100, 70, 900, 580]);
hold on;

semilogy(qpsk.EbNo_fine, qpsk.theo_gray_fine, '-', ...
    'Color', colors(1, :), 'LineWidth', 1.9, ...
    'DisplayName', 'Gray QPSK - Fig. 2 (Theory: $p$)');
semilogy(qpsk.EbNo_dB, qpsk.sim_gray, 'o', ...
    'Color', colors(1, :), 'MarkerSize', 7.5, 'LineWidth', 1.5, ...
    'DisplayName', 'Gray QPSK - Fig. 2 (Sim)');

semilogy(qpsk.EbNo_fine, qpsk.theo_nongray_fine, '--', ...
    'Color', colors(2, :), 'LineWidth', 1.9, ...
    'DisplayName', 'Non-Gray QPSK - Fig. 3 (Theory: $1.5p - p^2$)');
semilogy(qpsk.EbNo_dB, qpsk.sim_nongray, 's', ...
    'Color', colors(2, :), 'MarkerSize', 7.5, 'LineWidth', 1.5, ...
    'DisplayName', 'Non-Gray QPSK - Fig. 3 (Sim)');

set(gca, 'YScale', 'log', 'FontSize', 12, 'LineWidth', 1.1, 'Box', 'on');
grid on; grid minor;
xlim([min(qpsk.EbNo_dB), 12]);
ylim([1e-5, 1]);
xlabel('$E_b/N_0$ (dB)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Bit Error Rate (BER)', 'Interpreter', 'latex', 'FontSize', 14);
title('QPSK Bit Mapping Comparison: Gray (Fig. 2) vs. Non-Gray (Fig. 3)', ...
      'FontSize', 13.5, 'FontWeight', 'bold');
legend('Interpreter', 'latex', 'Location', 'southwest', 'FontSize', 11);
hold off;
save_if_enabled(f2, 'qpsk_cmp', export_figs);

%% ========================================================================
%  FIGURE 3: BFSK BER vs. Eb/N0 (Checklist #3 -> fig:bfsk_ber)
%  ========================================================================
f3 = figure('Name', 'fig:bfsk_ber - BFSK BER vs Eb/N0', ...
            'Color', 'w', 'Position', [140, 60, 880, 560]);
hold on;

semilogy(bfsk.EbNo_fine, bfsk.theo_ber_fine, '-', ...
    'Color', colors(5, :), 'LineWidth', 2.0, ...
    'DisplayName', 'Theory: $Q(\sqrt{E_b/N_0})$');
semilogy(bfsk.EbNo_dB, bfsk.sim_ber, 'd', ...
    'Color', [0.15, 0.15, 0.15], 'MarkerFaceColor', colors(5, :), ...
    'MarkerSize', 7, 'LineWidth', 1.3, 'DisplayName', 'Simulation (Baseband BFSK)');

set(gca, 'YScale', 'log', 'FontSize', 12, 'LineWidth', 1.1, 'Box', 'on');
grid on; grid minor;
xlim([min(bfsk.EbNo_dB), max(bfsk.EbNo_dB)]);
ylim([1e-5, 1]);
xlabel('$E_b/N_0$ (dB)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Bit Error Rate (BER)', 'Interpreter', 'latex', 'FontSize', 14);
title('Coherent Orthogonal BFSK BER Performance in AWGN', ...
      'FontSize', 13.5, 'FontWeight', 'bold');
legend('Interpreter', 'latex', 'Location', 'southwest', 'FontSize', 11.5);
hold off;
save_if_enabled(f3, 'bfsk_ber', export_figs);

%% ========================================================================
%  FIGURE 4: BFSK Baseband Welch PSD + Theory (Checklist #4 & #10 -> fig:bfsk_psd)
%  ========================================================================
f4 = figure('Name', 'fig:bfsk_psd - BFSK Baseband PSD', ...
            'Color', 'w', 'Position', [180, 50, 940, 580]);
hold on;

f_norm = bfsk.f_psd * bfsk.Tb;   % Normalized frequency f * Tb
plot(f_norm, 10*log10(bfsk.psd_sim + eps), '-', ...
    'Color', [0.0000, 0.4470, 0.7410], 'LineWidth', 1.3, ...
    'DisplayName', 'Welch PSD Estimate (Simulated)');
plot(f_norm, 10*log10(bfsk.psd_theo_cont + eps), '--', ...
    'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 2.0, ...
    'DisplayName', 'Theoretical Continuous PSD');

% Mark discrete spectral lines at f*Tb = +/- 0.5 (+/- 1/(2*Tb))
xline(-0.5, ':', 'Color', [0.2 0.6 0.2], 'LineWidth', 1.6, ...
      'DisplayName', 'Spectral Lines at $f = \pm 1/(2T_b)$');
xline(+0.5, ':', 'Color', [0.2 0.6 0.2], 'LineWidth', 1.6, ...
      'HandleVisibility', 'off');

set(gca, 'FontSize', 12, 'LineWidth', 1.1, 'Box', 'on');
grid on; grid minor;
xlim([-3.5, 3.5]);
ylim([-55, 15]);
xlabel('Normalized Frequency $f T_b$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Power Spectral Density (dB/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
title('Baseband Equivalent BFSK Power Spectral Density (Welch vs. Theory)', ...
      'FontSize', 13.5, 'FontWeight', 'bold');
legend('Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 11);
hold off;
save_if_enabled(f4, 'bfsk_psd', export_figs);

%% ========================================================================
%  FIGURE 5: Noisy Constellations at 5 dB & 15 dB (Checklist #5 -> fig:rx_consts)
%  ========================================================================
f5 = figure('Name', 'fig:rx_consts - Noisy Constellations (5 dB & 15 dB)', ...
            'Color', 'w', 'Position', [50, 40, 1280, 680]);

for row = 1:2
    if row == 1
        snaps = part1.rx_snap_5dB;
        snr_lbl = params.snap_snrs_dB(1);
    else
        snaps = part1.rx_snap_15dB;
        snr_lbl = params.snap_snrs_dB(2);
    end
    for m = 1:4
        subplot(2, 4, (row - 1)*4 + m);
        hold on;
        rx_pts = snaps{m};
        c_pts  = part1.constellations{m};

        plot(real(rx_pts), imag(rx_pts), '.', 'Color', [0.65, 0.80, 0.95], 'MarkerSize', 4);
        plot(real(c_pts),  imag(c_pts),  'o', 'MarkerEdgeColor', 'k', ...
             'MarkerFaceColor', colors(m, :), 'MarkerSize', 6, 'LineWidth', 1.1);

        xline(0, '--', 'Color', [0.5 0.5 0.5]);
        yline(0, '--', 'Color', [0.5 0.5 0.5]);
        axis equal; xlim([-1.7, 1.7]); ylim([-1.7, 1.7]);
        grid on; set(gca, 'FontSize', 9.5, 'Box', 'on');
        xlabel('$I$', 'Interpreter', 'latex');
        ylabel('$Q$', 'Interpreter', 'latex');
        title(sprintf('%s (%d dB)', part1.schemes{m}, snr_lbl), 'FontSize', 10.5);
        hold off;
    end
end
sgtitle('Received Noisy Constellations at E_b/N_0 = 5 dB (Top) and 15 dB (Bottom)', ...
        'FontSize', 13.5, 'FontWeight', 'bold');
save_if_enabled(f5, 'rx_consts', export_figs);

%% ========================================================================
%  FIGURE 6: Per-Scheme BER 2x2 Grid (Checklist #6 -> fig:ber_each)
%  ========================================================================
f6 = figure('Name', 'fig:ber_each - Per-Scheme BER (2x2 Grid)', ...
            'Color', 'w', 'Position', [120, 60, 1000, 680]);

for m = 1:4
    subplot(2, 2, m);
    semilogy(params.EbNo_fine, part1.theo_ber_fine(m, :), '-', ...
        'Color', colors(m, :), 'LineWidth', 1.8, 'DisplayName', 'Theory');
    hold on;
    semilogy(params.EbNo_dB, part1.sim_ber(m, :), markers{m}, ...
        'Color', [0.15, 0.15, 0.15], 'MarkerSize', 6.5, 'LineWidth', 1.3, ...
        'DisplayName', 'Simulation');
    hold off;

    set(gca, 'YScale', 'log', 'FontSize', 10.5, 'LineWidth', 1.0, 'Box', 'on');
    grid on; grid minor;
    xlim([min(params.EbNo_dB), max(params.EbNo_dB)]);
    ylim([1e-5, 1]);
    xlabel('$E_b/N_0$ (dB)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel('BER', 'Interpreter', 'latex', 'FontSize', 11);
    title(sprintf('%s (k = %d bits/sym)', part1.schemes{m}, part1.k_values(m)), ...
          'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'southwest', 'FontSize', 9.5);
end
save_if_enabled(f6, 'ber_each', export_figs);

%% ========================================================================
%  FIGURE 7: BFSK Baseband Time-Domain Waveform (Checklist #11)
%  ========================================================================
f7 = figure('Name', 'BFSK Baseband Time-Domain Waveform', ...
            'Color', 'w', 'Position', [200, 60, 940, 560]);

bit_str = sprintf('%d ', bfsk.bits_wave);

subplot(2, 1, 1);
plot(bfsk.t_wave / bfsk.Tb, real(bfsk.s_wave), '-', ...
    'Color', colors(1, :), 'LineWidth', 1.6, 'DisplayName', 'In-Phase $\mathrm{Re}\{g(t)\}$');
hold on;
plot(bfsk.t_wave / bfsk.Tb, imag(bfsk.s_wave), '--', ...
    'Color', colors(2, :), 'LineWidth', 1.6, 'DisplayName', 'Quadrature $\mathrm{Im}\{g(t)\}$');
for b = 1 : bfsk.n_wave_bits - 1
    xline(b, ':', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
end
hold off;
grid on; set(gca, 'FontSize', 11, 'Box', 'on');
xlim([0, bfsk.n_wave_bits]);
xlabel('Normalized Time $t / T_b$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Amplitude', 'Interpreter', 'latex', 'FontSize', 12);
title(sprintf('BFSK Baseband Equivalent Waveform (Bits: [ %s])', bit_str), ...
      'FontSize', 12.5, 'FontWeight', 'bold');
legend('Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 10.5);

subplot(2, 1, 2);
stairs(0 : bfsk.n_wave_bits, [bfsk.bits_wave, bfsk.bits_wave(end)], ...
       'Color', [0.2 0.2 0.2], 'LineWidth', 1.8);
grid on; set(gca, 'FontSize', 11, 'Box', 'on', 'YTick', [0 1]);
xlim([0, bfsk.n_wave_bits]); ylim([-0.25, 1.25]);
xlabel('Normalized Time $t / T_b$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Input Bit', 'Interpreter', 'latex', 'FontSize', 12);
title('Transmitted Binary Bit Stream (0 \rightarrow -1/(2T_b), 1 \rightarrow +1/(2T_b))', ...
      'FontSize', 11.5);
save_if_enabled(f7, 'bfsk_waveform', export_figs);

%% ========================================================================
%  LOCAL HELPER FUNCTIONS (Script-local helpers at bottom of plots.m)
%  ========================================================================
function ebno_req = find_ebno_at_ber(ebno_vec, ber_vec, target)
    % Finds Eb/N0 (dB) where BER crosses 'target' using log-linear interpolation
    idx = find(ber_vec <= target, 1, 'first');
    if isempty(idx) || idx == 1 || ber_vec(idx) <= 0
        ebno_req = NaN;
        return;
    end
    y1 = log10(ber_vec(idx - 1));
    y2 = log10(ber_vec(idx));
    x1 = ebno_vec(idx - 1);
    x2 = ebno_vec(idx);
    ebno_req = x1 + (log10(target) - y1) * (x2 - x1) / (y2 - y1);
end

function save_if_enabled(fig_handle, base_name, do_export)
    if do_export
        exportgraphics(fig_handle, fullfile('figures', [base_name '.png']), 'Resolution', 300);
    end
end