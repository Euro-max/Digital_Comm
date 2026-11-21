function bfsk = bfsk_analysis_psd(num_bits_ber, EbNo_dB, EbNo_fine, num_bits_psd, Tb, sps, seed)
% BFSK_ANALYSIS_PSD Simulates coherent orthogonal BFSK BER, baseband Welch PSD,
% theoretical PSD overlay, and baseband time-domain waveform.
%
% Signal model (Section 1.5):
%   f_1 = (n_c + 1)/Tb,  f_2 = (n_c + 2)/Tb  =>  Delta_f = 1/Tb
%   Carrier center frequency: f_c = (n_c + 1.5)/Tb
%   Baseband equivalent: g_i(t) = sqrt(2*Eb/Tb) * exp(j * 2*pi * (+/- 1/(2*Tb)) * t)

    rng(seed);
    num_snr = length(EbNo_dB);

    %% 1. Baseband BFSK BER Simulation (using mapper -> awgn_channel -> demapper)
    sim_ber = zeros(1, num_snr);
    for s = 1:num_snr
        tx_bits = randi([0 1], 1, num_bits_ber);
        [tx_sym, k, const] = mapper(tx_bits, 'BFSK');
        rx_sym  = awgn_channel(tx_sym, EbNo_dB(s), k);
        rx_bits = demapper(rx_sym, const, k);
        sim_ber(s) = mean(tx_bits ~= rx_bits);
    end

    %% 2. Baseband Equivalent Signal Generation for PSD & Waveform
    Eb = 1;                             % Normalized bit energy
    fs = sps / Tb;                      % Sampling frequency (Hz)
    f_dev = 1 / (2 * Tb);               % Frequency offset +/- 1/(2*Tb)

    bits_psd = randi([0 1], 1, num_bits_psd);
    a_n      = 2 * bits_psd - 1;        % Map {0, 1} -> {-1, +1}
    a_t      = repelem(a_n, sps);       % Oversample to sps samples per bit
    t        = (0 : length(a_t) - 1) / fs;

    % Continuous-phase baseband equivalent signal (Sunde's FSK, h = 1)
    s_bb = sqrt(2 * Eb / Tb) * exp(1j * 2 * pi * f_dev * a_t .* t);

    %% 3. Welch PSD Estimate (Baseband, Two-Sided Centered)
    win_len  = 512;
    noverlap = 256;
    nfft     = 4096;
    [psd_sim, f_psd] = pwelch(s_bb, hamming(win_len), noverlap, nfft, fs, 'centered');

    %% 4. Theoretical Continuous Baseband PSD (Sunde's FSK)
    % S_B(f) = (Eb/(2*Tb))*[delta(f - 1/(2*Tb)) + delta(f + 1/(2*Tb))]
    %          + (8*Eb/pi^2) * cos^2(pi*f*Tb) / (1 - 4*f^2*Tb^2)^2
    u     = f_psd * Tb;                 % Normalized frequency f * Tb
    denom = 1 - 4 * u.^2;
    psd_theo_cont = (8 * Eb / pi^2) * (cos(pi * u) ./ denom).^2;

    % Handle removable 0/0 singularity at f*Tb = +/- 0.5 (limit = Eb/2)
    sing_idx = abs(denom) < 1e-10;
    psd_theo_cont(sing_idx) = Eb / 2;

    %% 5. Extract Short Time-Domain Segment (First 8 Bits) for Waveform Plot
    n_wave_bits = 8;
    n_wave_samp = n_wave_bits * sps;

    %% 6. Pack Output Struct
    bfsk.EbNo_dB       = EbNo_dB;
    bfsk.EbNo_fine     = EbNo_fine;
    bfsk.sim_ber       = sim_ber;
    bfsk.theo_ber      = theoretical_ber(EbNo_dB,   'BFSK');
    bfsk.theo_ber_fine = theoretical_ber(EbNo_fine, 'BFSK');

    bfsk.Tb            = Tb;
    bfsk.sps           = sps;
    bfsk.fs            = fs;
    bfsk.f_psd         = f_psd;
    bfsk.psd_sim       = psd_sim;
    bfsk.psd_theo_cont = psd_theo_cont;
    bfsk.f_lines       = [-f_dev, f_dev];

    bfsk.n_wave_bits   = n_wave_bits;
    bfsk.bits_wave     = bits_psd(1:n_wave_bits);
    bfsk.t_wave        = t(1:n_wave_samp);
    bfsk.s_wave        = s_bb(1:n_wave_samp);
end