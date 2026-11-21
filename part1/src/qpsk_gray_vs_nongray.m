function qpsk = qpsk_gray_vs_nongray(num_bits, EbNo_dB, EbNo_fine, seed)
% QPSK_GRAY_VS_NONGRAY Compares Gray QPSK (Fig. 2) vs. Non-Gray QPSK (Fig. 3).
%
% Output struct 'qpsk' contains simulated and theoretical BER curves for plots.m.

    rng(seed);
    num_snr = length(EbNo_dB);

    sim_gray    = zeros(1, num_snr);
    sim_nongray = zeros(1, num_snr);

    for s = 1:num_snr
        % Use identical random bits for a fair side-by-side comparison
        tx_bits = randi([0 1], 1, num_bits);

        % Gray-coded QPSK (Figure 2)
        [tx_g, k, const_g] = mapper(tx_bits, 'QPSK');
        rx_g      = awgn_channel(tx_g, EbNo_dB(s), k);
        rx_bits_g = demapper(rx_g, const_g, k);
        sim_gray(s) = mean(tx_bits ~= rx_bits_g);

        % Non-Gray QPSK (Figure 3)
        [tx_ng, k, const_ng] = mapper(tx_bits, 'QPSK_NONGRAY');
        rx_ng      = awgn_channel(tx_ng, EbNo_dB(s), k);
        rx_bits_ng = demapper(rx_ng, const_ng, k);
        sim_nongray(s) = mean(tx_bits ~= rx_bits_ng);
    end

    % Store all results in a struct
    qpsk.EbNo_dB           = EbNo_dB;
    qpsk.EbNo_fine         = EbNo_fine;
    qpsk.sim_gray          = sim_gray;
    qpsk.sim_nongray       = sim_nongray;
    qpsk.theo_gray         = theoretical_ber(EbNo_dB,   'QPSK');
    qpsk.theo_nongray      = theoretical_ber(EbNo_dB,   'QPSK_NONGRAY');
    qpsk.theo_gray_fine    = theoretical_ber(EbNo_fine, 'QPSK');
    qpsk.theo_nongray_fine = theoretical_ber(EbNo_fine, 'QPSK_NONGRAY');
end