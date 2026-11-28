clear; clc; close all;
num_frames = 30000;
EbNo_dB = -4:2:20;
tic;
% Preallocating BER arrays for all 8 branches
ber_bpsk_uncoded_RF  = zeros(size(EbNo_dB)); %RF: Rayleigh Fading Channel
ber_bpsk_coded_RF    = zeros(size(EbNo_dB));
ber_bpsk_uncoded_FS  = zeros(size(EbNo_dB)); %FS: Frequecny Selective Channel
ber_bpsk_coded_FS    = zeros(size(EbNo_dB));

ber_16qam_uncoded_RF = zeros(size(EbNo_dB));
ber_16qam_coded_RF   = zeros(size(EbNo_dB));
ber_16qam_uncoded_FS = zeros(size(EbNo_dB));
ber_16qam_coded_FS   = zeros(size(EbNo_dB));

parfor idx = 1:length(EbNo_dB)
%Initializing BER per SNR
err_bpsk_uncoded_RF  = 0;
err_bpsk_coded_RF    = 0;
err_bpsk_uncoded_FS  = 0;
err_bpsk_coded_FS    = 0;

err_16qam_uncoded_RF = 0;
err_16qam_coded_RF   = 0;
err_16qam_uncoded_FS = 0;
err_16qam_coded_FS   = 0;

bits_bpsk_coded = zeros(256, 1);
bits_16qam_coded = zeros(1024, 1);

No = 10^(-(EbNo_dB(idx)/10));

for frame= 1: num_frames
%% %%%%%%%%%%%%%%%%%% Transmitter %%%%%%%%%%%%%%%%%%%%% %%
%% Data Initialization
%data that will NOT be coded
bits_bpsk_uncoded  = randi([0 1], 256, 1);  
bits_16qam_uncoded = randi([0 1], 1024, 1);

%data to be coded
bits_bpsk_2Bcoded = randi([0 1], 51, 1);
bits_16qam_2Bcoded = randi([0 1], 204, 1);


%% Coding 
%using rate 1/5 repetition code
bits_bpsk_coded(1:255) = repelem(bits_bpsk_2Bcoded, 5);
bits_16qam_coded(1:1020) = repelem(bits_16qam_2Bcoded, 5);

%zero padding
bits_bpsk_coded(256) = 0;
bits_16qam_coded(1021:1024) = zeros(4,1);


%% Interleaver
bits_bpsk_uncoded_interleaved = matintrlv(bits_bpsk_uncoded, 32, 8);
bits_bpsk_coded_interleaved = matintrlv(bits_bpsk_coded, 32, 8);
bits_16qam_uncoded_interleaved = matintrlv (bits_16qam_uncoded, 32, 32);
bits_16qam_coded_interleaved = matintrlv (bits_16qam_coded, 32, 32);


%% Mapper
symbols_bpsk_uncoded = -pskmod(bits_bpsk_uncoded_interleaved, 2, ...
    'InputType', 'bit'); %negative sign is added for compatibility with fig2
symbols_bpsk_coded = -pskmod(bits_bpsk_coded_interleaved, 2, ...
    'InputType', 'bit');
symbols_16qam_uncoded = sqrt(4) *conj(qammod (bits_16qam_uncoded_interleaved, ...
    16, 'InputType','bit','UnitAveragePower', true ));
                            %conjugation is added for compatibility with fig2
                            %power is multiplied by 4 to normalize Eb
symbols_16qam_coded = sqrt(4) *conj(qammod (bits_16qam_coded_interleaved, ...
    16, 'InputType','bit', 'UnitAveragePower', true ));


%% Frequency Selective Fading channel
h_freq_selective = sqrt(1/2)* (randn(256, 1) + 1j*randn(256,1));

symbols_bpsk_uncoded_FS = h_freq_selective.*symbols_bpsk_uncoded;
symbols_bpsk_coded_FS   = h_freq_selective.*symbols_bpsk_coded;
symbols_16qam_uncoded_FS = h_freq_selective.*symbols_16qam_uncoded;
symbols_16qam_coded_FS = h_freq_selective.*symbols_16qam_coded;


%% IFFT
time_signal_bpsk_uncoded = sqrt(256) * ifft (symbols_bpsk_uncoded);
time_signal_bpsk_coded = sqrt(256) * ifft (symbols_bpsk_coded);
time_signal_16qam_uncoded = sqrt(256) * ifft (symbols_16qam_uncoded);
time_signal_16qam_coded = sqrt(256) * ifft (symbols_16qam_coded);

tx_bpsk_uncoded_FS = sqrt(256) * ifft(symbols_bpsk_uncoded_FS);
tx_bpsk_coded_FS = sqrt(256) * ifft(symbols_bpsk_coded_FS);
tx_16qam_uncoded_FS = sqrt(256) * ifft(symbols_16qam_uncoded_FS);
tx_16qam_coded_FS = sqrt(256) * ifft(symbols_16qam_coded_FS);


%% Rayleigh Flat Fading Channel
h = sqrt(1/2) * (randn + 1j * randn);
tx_bpsk_uncoded_RF  = h * time_signal_bpsk_uncoded; 
tx_bpsk_coded_RF    = h * time_signal_bpsk_coded;
tx_16qam_uncoded_RF = h * time_signal_16qam_uncoded;
tx_16qam_coded_RF   = h * time_signal_16qam_coded;


%% AWGN
noise = sqrt(No/2) * (randn(256, 1) + 1j * randn(256, 1));
rx_bpsk_uncoded_RF = tx_bpsk_uncoded_RF + noise;
rx_bpsk_coded_RF = tx_bpsk_coded_RF + noise;
rx_16qam_uncoded_RF = tx_16qam_uncoded_RF + noise;
rx_16qam_coded_RF = tx_16qam_coded_RF + noise;

rx_bpsk_uncoded_FS = tx_bpsk_uncoded_FS + noise;
rx_bpsk_coded_FS = tx_bpsk_coded_FS + noise;
rx_16qam_uncoded_FS = tx_16qam_uncoded_FS + noise;
rx_16qam_coded_FS = tx_16qam_coded_FS + noise;



%% %%%%%%%%%%%%%%%%% Receiver %%%%%%%%%%%%%%%%% %%
%% Rayleigh Channel Equalizer
rx_bpsk_uncoded_RF_equalized = rx_bpsk_uncoded_RF /h;
rx_bpsk_coded_RF_equalized = rx_bpsk_coded_RF /h;
rx_16qam_uncoded_RF_equalized = rx_16qam_uncoded_RF /h;
rx_16qam_coded_RF_equalized = rx_16qam_coded_RF /h;


%% FFT
rx_symbols_bpsk_uncoded_RF = (1/sqrt (256)) * fft(rx_bpsk_uncoded_RF_equalized);
rx_symbols_bpsk_coded_RF = (1/sqrt (256)) * fft(rx_bpsk_coded_RF_equalized);
rx_symbols_16qam_uncoded_RF = (1/sqrt (256)) * fft(rx_16qam_uncoded_RF_equalized);
rx_symbols_16qam_coded_RF = (1/sqrt (256)) * fft(rx_16qam_coded_RF_equalized);

rx_symbols_bpsk_uncoded_FS = (1/sqrt(256)) * fft (rx_bpsk_uncoded_FS);
rx_symbols_bpsk_coded_FS = (1/sqrt(256)) * fft (rx_bpsk_coded_FS);
rx_symbols_16qam_uncoded_FS = (1/sqrt(256)) * fft (rx_16qam_uncoded_FS);
rx_symbols_16qam_coded_FS = (1/sqrt(256)) * fft (rx_16qam_coded_FS);


%% Frequency Selective Fading Channel Equalizer
rx_symbols_bpsk_uncoded_FS_equalized =rx_symbols_bpsk_uncoded_FS ./h_freq_selective;
rx_symbols_bpsk_coded_FS_equalized =rx_symbols_bpsk_coded_FS ./h_freq_selective;
rx_symbols_16qam_uncoded_FS_equalized=rx_symbols_16qam_uncoded_FS ./h_freq_selective;
rx_symbols_16qam_coded_FS_equalized =rx_symbols_16qam_coded_FS ./h_freq_selective;


%% Demapper
%BPSK Demapping
rx_bits_bpsk_uncoded_RF_int  = pskdemod(-rx_symbols_bpsk_uncoded_RF, 2, ...
    'OutputType', 'bit');
rx_bits_bpsk_coded_RF_int    = pskdemod(-rx_symbols_bpsk_coded_RF, 2,...
    'OutputType', 'bit');
rx_bits_bpsk_uncoded_FS_int  = pskdemod(-rx_symbols_bpsk_uncoded_FS_equalized, 2,...
    'OutputType', 'bit');
rx_bits_bpsk_coded_FS_int    = pskdemod(-rx_symbols_bpsk_coded_FS_equalized, 2,...
    'OutputType', 'bit');

%16QAM Demapping
rx_bits_16qam_uncoded_RF_int = qamdemod(conj(rx_symbols_16qam_uncoded_RF) / ...
    sqrt(4), 16, 'OutputType', 'bit', 'UnitAveragePower', true);
rx_bits_16qam_coded_RF_int   = qamdemod(conj(rx_symbols_16qam_coded_RF) / ...
    sqrt(4), 16, 'OutputType', 'bit', 'UnitAveragePower', true);
rx_bits_16qam_uncoded_FS_int = ...
    qamdemod(conj(rx_symbols_16qam_uncoded_FS_equalized)/ sqrt(4), ...
    16, 'OutputType', 'bit', 'UnitAveragePower', true);
rx_bits_16qam_coded_FS_int   = ...
    qamdemod(conj(rx_symbols_16qam_coded_FS_equalized)/ sqrt(4),...
    16, 'OutputType', 'bit', 'UnitAveragePower', true);


%% Deinterleaver
% BPSK deinterleaving
rx_bits_bpsk_uncoded_RF_deint = matdeintrlv(rx_bits_bpsk_uncoded_RF_int, 32, 8);
rx_bits_bpsk_coded_RF_deint = matdeintrlv(rx_bits_bpsk_coded_RF_int, 32, 8);
rx_bits_bpsk_uncoded_FS_deint = matdeintrlv(rx_bits_bpsk_uncoded_FS_int, 32, 8);
rx_bits_bpsk_coded_FS_deint = matdeintrlv(rx_bits_bpsk_coded_FS_int, 32, 8);

%16QAM deinterleaving
rx_bits_16qam_uncoded_RF_deint = matdeintrlv(rx_bits_16qam_uncoded_RF_int, 32, 32);
rx_bits_16qam_coded_RF_deint = matdeintrlv(rx_bits_16qam_coded_RF_int, 32, 32);
rx_bits_16qam_uncoded_FS_deint = matdeintrlv(rx_bits_16qam_uncoded_FS_int, 32, 32);
rx_bits_16qam_coded_FS_deint = matdeintrlv(rx_bits_16qam_coded_FS_int, 32, 32);


%% Decoding
%Unpadding
rx_bits_bpsk_coded_RF_unpadded = rx_bits_bpsk_coded_RF_deint(1:255);
rx_bits_bpsk_coded_FS_unpadded = rx_bits_bpsk_coded_FS_deint(1:255);
rx_bits_16qam_coded_RF_unpadded = rx_bits_16qam_coded_RF_deint(1:1020);
rx_bits_16qam_coded_FS_unpadded = rx_bits_16qam_coded_FS_deint(1:1020);

%Collecting each 5 consecuative bits in a row
rx_bits_bpsk_coded_RF_col = reshape (rx_bits_bpsk_coded_RF_unpadded, 5, []).';
rx_bits_bpsk_coded_FS_col = reshape (rx_bits_bpsk_coded_FS_unpadded, 5, []).';
rx_bits_16qam_coded_RF_col = reshape (rx_bits_16qam_coded_RF_unpadded, 5, []).';
rx_bits_16qam_coded_FS_col = reshape (rx_bits_16qam_coded_FS_unpadded, 5, []).';

%Summing elements of each row
rx_bits_bpsk_coded_RF_summed = sum (rx_bits_bpsk_coded_RF_col, 2);
rx_bits_bpsk_coded_FS_summed = sum (rx_bits_bpsk_coded_FS_col, 2);
rx_bits_16qam_coded_RF_summed = sum (rx_bits_16qam_coded_RF_col, 2);
rx_bits_16qam_coded_FS_summed = sum (rx_bits_16qam_coded_FS_col, 2);

%Decision making according to majority voting of threshold = 3 --> 
%(>=3 bk=1, <3 bk=0)
rx_bits_bpsk_decoded_RF = rx_bits_bpsk_coded_RF_summed >=3;
rx_bits_bpsk_decoded_FS = rx_bits_bpsk_coded_FS_summed >=3;
rx_bits_16qam_decoded_RF = rx_bits_16qam_coded_RF_summed >=3;
rx_bits_16qam_decoded_FS = rx_bits_16qam_coded_FS_summed >=3;

%% Accumulating number of errors from previous frames of the same SNR
% Accumulate frame BER for all 8 branches
err_bpsk_uncoded_RF  = err_bpsk_uncoded_RF  + ...
    mean(bits_bpsk_uncoded  ~= rx_bits_bpsk_uncoded_RF_deint);
err_bpsk_coded_RF    = err_bpsk_coded_RF    +...
    mean(bits_bpsk_2Bcoded  ~= rx_bits_bpsk_decoded_RF);
err_bpsk_uncoded_FS  = err_bpsk_uncoded_FS  + ...
    mean(bits_bpsk_uncoded  ~= rx_bits_bpsk_uncoded_FS_deint);
err_bpsk_coded_FS    = err_bpsk_coded_FS    + ...
    mean(bits_bpsk_2Bcoded  ~= rx_bits_bpsk_decoded_FS);

err_16qam_uncoded_RF = err_16qam_uncoded_RF + ...
    mean(bits_16qam_uncoded ~= rx_bits_16qam_uncoded_RF_deint);
err_16qam_coded_RF   = err_16qam_coded_RF   + ...
    mean(bits_16qam_2Bcoded ~= rx_bits_16qam_decoded_RF);
err_16qam_uncoded_FS = err_16qam_uncoded_FS + ...
    mean(bits_16qam_uncoded ~= rx_bits_16qam_uncoded_FS_deint);
err_16qam_coded_FS   = err_16qam_coded_FS   + ...
    mean(bits_16qam_2Bcoded ~= rx_bits_16qam_decoded_FS);
end


%% Calculating BER
% Uncoded streams
ber_bpsk_uncoded_RF(idx)  = err_bpsk_uncoded_RF  / num_frames;
ber_bpsk_uncoded_FS(idx)  = err_bpsk_uncoded_FS  / num_frames;
ber_16qam_uncoded_RF(idx) = err_16qam_uncoded_RF / num_frames;
ber_16qam_uncoded_FS(idx) = err_16qam_uncoded_FS / num_frames;

% Coded streams
ber_bpsk_coded_RF(idx)    = err_bpsk_coded_RF    / num_frames;
ber_bpsk_coded_FS(idx)    = err_bpsk_coded_FS    / num_frames;
ber_16qam_coded_RF(idx)   = err_16qam_coded_RF   / num_frames;
ber_16qam_coded_FS(idx)   = err_16qam_coded_FS   / num_frames;
end
%% Displaying Simulation Time
elapsed = toc;
fprintf('Estimated full runtime: %.1f minutes\n', (elapsed/60))

%% %%%%%%%%%%%%%%%% Plotting Sections %%%%%%%%%%%%%%%%%%% %%
%% Theoretical BER Curves (Uncoded & Coded 1/5)
close all;
% Uncoded (Diversity Order = 1)
ber_theo_bpsk  = berfading(EbNo_dB, 'psk', 2, 1);
ber_theo_16qam = berfading(EbNo_dB, 'qam', 16, 1);

% Coded (Rate-1/5 Majority Voting over Independent Fades)
ber_theo_bpsk_coded  = 10 .* (1 - ber_theo_bpsk).^2  .* ber_theo_bpsk.^3  + ...
                        5 .* (1 - ber_theo_bpsk)     .* ber_theo_bpsk.^4  + ...
                             ber_theo_bpsk.^5;
ber_theo_16qam_b0 = 2/3 * ber_theo_16qam;
ber_theo_16qam_b1 = 2 * ber_theo_16qam_b0;
ber_theo_16qam_coded = ...
0.5*(10 .* (1 - ber_theo_16qam_b0).^2 .* ber_theo_16qam_b0.^3 + ...
      5 .* (1 - ber_theo_16qam_b0)    .* ber_theo_16qam_b0.^4 + ...
                ber_theo_16qam_b0.^5) + ...
0.5*(10 .* (1 - ber_theo_16qam_b1).^2 .* ber_theo_16qam_b1.^3 + ...
      5 .* (1 - ber_theo_16qam_b1)    .* ber_theo_16qam_b1.^4 + ...
             ber_theo_16qam_b1.^5);

%% Plotting BER vs Eb/No (Subplots by Modulation Scheme) with comparison to
figure('Position', [100, 100, 1200, 500]);

% Left Subplot: BPSK
subplot(1, 2, 1);
semilogy(EbNo_dB, ber_bpsk_uncoded_RF, 'b--', 'LineWidth', 1.5); hold on;
semilogy(EbNo_dB, ber_bpsk_uncoded_FS, 'r--', 'LineWidth', 1.5);
semilogy(EbNo_dB, ber_theo_bpsk,       'k:',  'LineWidth', 2);
semilogy(EbNo_dB, ber_bpsk_coded_RF,   'b-',  'LineWidth', 1.5);
semilogy(EbNo_dB, ber_bpsk_coded_FS,   'r-',  'LineWidth', 1.5);
semilogy(EbNo_dB, ber_theo_bpsk_coded, 'k-',  'LineWidth', 1.5);
grid on;
ylim([1e-4 1]);
xlim([min(EbNo_dB) max(EbNo_dB)]);
xlabel('E_b / N_0 (dB)', 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontWeight', 'bold');
title('BPSK');
legend('Rayleigh Flat Fading - Uncoded', ...
       'Freq-Selective - Uncoded', ...
       'Theoretical Uncoded', ...
       'Rayleigh Flat Fading - Coded (1/5)', ...
       'Freq-Selective - Coded (1/5)', ...
       'Theoretical Freq-Selective Coded (1/5)', ...
       'Location', 'southwest');

% Right Subplot: 16-QAM
subplot(1, 2, 2);
semilogy(EbNo_dB, ber_16qam_uncoded_RF, 'b--', 'LineWidth', 1.5); hold on;
semilogy(EbNo_dB, ber_16qam_uncoded_FS, 'r--', 'LineWidth', 1.5);
semilogy(EbNo_dB, ber_theo_16qam,       'k:',  'LineWidth', 2);
semilogy(EbNo_dB, ber_16qam_coded_RF,   'b-',  'LineWidth', 1.5);
semilogy(EbNo_dB, ber_16qam_coded_FS,   'r-',  'LineWidth', 1.5);
semilogy(EbNo_dB, ber_theo_16qam_coded, 'k-',  'LineWidth', 1.5);
grid on;
ylim([1e-4 1]);
xlim([min(EbNo_dB) max(EbNo_dB)]);
xlabel('E_b / N_0 (dB)', 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontWeight', 'bold');
title('16-QAM');
legend('Rayleigh Flat Fading - Uncoded', ...
       'Freq-Selective - Uncoded', ...
       'Theoretical Uncoded', ...
       'Rayleigh Flat Fading - Coded (1/5)', ...
       'Freq-Selective - Coded (1/5)', ...
       'Theoretical Freq-Selective Coded (1/5)', ...
       'Location', 'southwest');

%% Figure 2: All 8 Simulated BER Curves on a Single Figure
figure('Position', [150, 150, 950, 600]);

% Uncoded Curves (Dashed Lines)
semilogy(EbNo_dB, ber_16qam_uncoded_RF, 'm--', 'LineWidth', 1.5); hold on;
semilogy(EbNo_dB, ber_16qam_uncoded_FS, 'r--', 'LineWidth', 1.5);
semilogy(EbNo_dB, ber_bpsk_uncoded_RF,  'b--', 'LineWidth', 1.5);
semilogy(EbNo_dB, ber_bpsk_uncoded_FS,  '--',  'Color', [0 0.6 0],...
    'LineWidth', 1.5);

% Coded Curves (Solid Lines)
semilogy(EbNo_dB, ber_16qam_coded_RF,   'm-',  'LineWidth', 1.5);
semilogy(EbNo_dB, ber_bpsk_coded_RF,    'b-',  'LineWidth', 1.5);
semilogy(EbNo_dB, ber_16qam_coded_FS,   'r-',  'LineWidth', 1.5);
semilogy(EbNo_dB, ber_bpsk_coded_FS,    '-',   'Color', [0 0.6 0], ...
    'LineWidth', 1.5);

grid on;
ylim([1e-4 1]);
xlim([min(EbNo_dB) max(EbNo_dB)]);
xlabel('E_b / N_0 (dB)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Bit Error Rate (BER)', 'FontSize', 11, 'FontWeight', 'bold');
title('Simulated OFDM BER Performance: BPSK vs. 16-QAM (All 8 Cases)',...
    'FontSize', 12);

legend('16-QAM Rayleigh Flat - Uncoded', ...
       '16-QAM Freq-Selective - Uncoded', ...
       'BPSK Rayleigh Flat - Uncoded', ...
       'BPSK Freq-Selective - Uncoded', ...
       '16-QAM Rayleigh Flat - Coded (1/5)', ...
       'BPSK Rayleigh Flat - Coded (1/5)', ...
       '16-QAM Freq-Selective - Coded (1/5)', ...
       'BPSK Freq-Selective - Coded (1/5)', ...
       'Location', 'southwest');






