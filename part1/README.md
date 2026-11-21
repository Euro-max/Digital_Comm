# Single-Carrier Digital Modulation: Performance over AWGN
**EECG331: Advanced Communication Systems — Project Part I**  
**Electronics and Communications Department | Faculty of Engineering, Cairo University**  
*Academic Year: 2026/2027*

---

## 👥 Authors & Supervision

| Student Name | Student ID | Section | Bench Number (BN) |
| :--- | :---: | :---: | :---: |
| **Ahmed Wael Mohammed** | 91240930 | 1 | 16 |
| **Adham Mohamed elSadiq** | 91240142 | 1 | 17 |
| **Kerolos Samir Karas** | 91240586 | 3 | 7 |

- **Course Instructor:** Dr. Mohammed Khairy  
- **Teaching Assistant:** Eng. Mohammed Khaled  
- **Repository Branch:** `part-1`  
- **Deliverables:** Complete simulation code ([`src/`](./src)), publication-quality plots ([`results/`](./results)), and comprehensive technical report ([`report/Single-Carrier Digital Modulation.pdf`](./report/Single-Carrier%20Digital%20Modulation.pdf)).

---

## 📌 Executive Summary

This project implements a modular, high-performance Monte Carlo simulation of a **single-carrier digital communication system** over an Additive White Gaussian Noise (AWGN) channel at **baseband equivalence** (no RF carriers). 

The investigation covers five digital modulation schemes (**BPSK**, **QPSK**, **8-PSK**, **16-QAM**, and **coherent orthogonal BFSK**), rigorous evaluation of symbol mapping impacts (comparing **Gray-coded QPSK** vs. the non-Gray mapping of Figure 3), and analytical derivation and simulation of the **BFSK baseband equivalent signal and Power Spectral Density (PSD)**.

All simulations use $N = 1.20 \times 10^6$ bits per $E_b/N_0$ point (divisible by $\text{lcm}(1,2,3,4) = 12$) over an $E_b/N_0$ sweep from $-2\text{ dB}$ to $15\text{ dB}$ (step $1\text{ dB}$), with fixed seed `rng(42)` for exact reproducibility. Across all schemes, simulated results track analytical theory within $\le 0.12\text{ dB}$ down to $\text{BER} \approx 10^{-5}$.

---

## 🏗️ System Architecture & Block Diagram

```text
Data Bits bk           Transmitted Symbols xk           Received Symbols yk         Decided Bits b̂k
{0, 1}^N      +------------+  (Normalized Es = 1)   +---+  (Es/N0 scaling)  +------------+   {0, 1}^N   +------------+
------------> |   MAPPER   | ---------------------> | + | ----------------> |  DEMAPPER  | -----------> |    BER     |
              +------------+                        +---+                   | (Min-Dist) |              | CALCULATOR |
                                                      ^                     +------------+              +------------+
                                                      |                                                       |
                                               Noise nk ~ CN(0, N0)                                           |
                                               sigma*(randn + 1j*randn)                                       v
                                                                                                    BER = mean(bk ~= b̂k)
```

### Modular Building Blocks:
1. **Mapper ([`src/mapper.m`](./src/mapper.m)):**
   - Groups input bits into symbols of $k = \log_2(M)$ bits.
   - Converts binary bit sequences to decimal symbol indices using vectorized bit weights ($2^{k-1:-1:0}$).
   - Normalizes constellation points to unit average symbol energy ($E_s = 1$), ensuring bit energy is consistently $E_b = E_s / k = 1/k$.
2. **AWGN Channel ([`src/awgn_channel.m`](./src/awgn_channel.m)):**
   - Generates complex Gaussian noise strictly using MATLAB's `randn`:
     $$\sigma = \sqrt{\frac{N_0}{2}} = \sqrt{\frac{E_b}{2 \cdot 10^{(E_b/N_0)_{\text{dB}} / 10}}}$$
     $$n_k = \sigma \cdot \left(\text{randn} + j \cdot \text{randn}\right)$$
3. **Demapper ([`src/demapper.m`](./src/demapper.m)):**
   - Implements universal Maximum Likelihood (ML) / Minimum Euclidean Distance detection:
     $$\hat{s}_k = \arg\min_{s_m \in \mathcal{C}} |y_k - s_m|^2$$
   - Matrix-vectorized across all received symbols without loops, decoding symbol indices back into $k$ binary bits via `bitget`.
4. **Theoretical Calculations ([`src/theoretical_ber.m`](./src/theoretical_ber.m)):**
   - Implements exact formulas and tight union bounds using the complementary error function (`erfc`) via the identity $Q(x) = \frac{1}{2} \text{erfc}(x/\sqrt{2})$, eliminating any dependency on external toolboxes.

---

## 🔬 Mathematical Formulations & Tasks Addressed

### Task 1: Multi-Modulation Comparison (BPSK, QPSK, 8PSK, 16-QAM)

| Scheme | $k$ (bits/sym) | Constellation Coordinates $x_k$ | $E_s$ | $E_b$ | $d_{\min}^2 / E_b$ | Theoretical BER $P_b$ |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **BPSK** | 1 | $\{-1, +1\}$ | 1 | 1 | 4.000 | $Q\left(\sqrt{\frac{2E_b}{N_0}}\right) = \frac{1}{2}\text{erfc}\left(\sqrt{\gamma}\right)$ |
| **QPSK (Gray)** | 2 | $\{\pm 1 \pm j\} / \sqrt{2}$ | 1 | 0.5 | 4.000 | $Q\left(\sqrt{\frac{2E_b}{N_0}}\right) = \frac{1}{2}\text{erfc}\left(\sqrt{\gamma}\right)$ |
| **8-PSK (Gray)** | 3 | $e^{j \pi m / 4}, \; m=0,\dots,7$ | 1 | $1/3$ | $12\sin^2(\frac{\pi}{8}) \approx 1.757$ | $\approx \frac{2}{3} Q\left(\sqrt{\frac{6E_b}{N_0}}\sin\frac{\pi}{8}\right) = \frac{1}{3}\text{erfc}\left(\sqrt{3\gamma}\sin\frac{\pi}{8}\right)$ |
| **16-QAM (Gray)**| 4 | $(\{\pm 1, \pm 3\} + j\{\pm 1, \pm 3\})/\sqrt{10}$ | 1 | 0.25 | 1.600 | $\approx \frac{3}{8} Q\left(\sqrt{\frac{4}{5}\frac{E_b}{N_0}}\right) = \frac{3}{8}\text{erfc}\left(\sqrt{\frac{2\gamma}{5}}\right)$ |

**Key Insights:**
- **BPSK vs. QPSK:** Both curves coincide exactly. QPSK transmits two independent BPSK streams on orthogonal in-phase and quadrature axes, doubling spectral efficiency ($2\text{ bits/s/Hz}$) with **0 dB energy penalty**.
- **8-PSK vs. 16-QAM Tradeoff:** 8-PSK has a larger normalized minimum distance ($d_{\min}^2/E_b \approx 1.76$ vs. $1.60$) and thus outperforms 16-QAM in power efficiency by $\approx 0.49\text{ dB}$ at $\text{BER} = 10^{-4}$. However, 16-QAM provides higher spectral efficiency ($4\text{ bits/s/Hz}$ vs. $3\text{ bits/s/Hz}$) by utilizing both amplitude and phase dimensions.

---

### Task 2: QPSK Gray Mapping (Fig. 2) vs. Non-Gray Mapping (Fig. 3)

The two mappings have identical decision boundaries (the four Cartesian quadrants) and identical Symbol Error Rate $P_s = 2p - p^2$, where $p = Q(\sqrt{2E_b/N_0})$. However, they differ significantly in their bit-to-symbol allocation:
- **Gray Coded (Figure 2):** Adjacent quadrants differ by only 1 bit ($01 \leftrightarrow 11 \leftrightarrow 10 \leftrightarrow 00$). A nearest-neighbor symbol error incurs exactly **1 bit error**.
- **Non-Gray (Figure 3):** Horizontal neighbors ($01 \leftrightarrow 10$ and $00 \leftrightarrow 11$) differ in **both bits**.

#### Exact Bit Error Rate Derivation:
$$\begin{aligned}
P_{b,\text{Non-Gray}} &= \frac{1}{2} \Big[ 2 \cdot p(1-p) + 1 \cdot p(1-p) + 1 \cdot p^2 \Big] \\
&= \frac{1}{2} \left[ 3p(1-p) + p^2 \right] = \frac{3}{2}p - p^2
\end{aligned}$$

At high SNR ($p \ll 1$), the ratio of bit error rates is:
$$\lim_{\text{SNR} \to \infty} \frac{P_{b,\text{Non-Gray}}}{P_{b,\text{Gray}}} = \frac{\frac{3}{2}p}{p} = 1.5 \quad (+1.76\text{ dB in BER})$$

At $\text{BER} = 10^{-4}$, non-Gray mapping requires $8.51\text{ dB}$ simulated ($8.63\text{ dB}$ theoretical) vs. $8.35\text{ dB}$ for Gray coding—a horizontal power penalty of $\approx 0.2\text{ dB}$ purely due to bit assignment!

---

### Task 3: Coherent BFSK Signal Analysis & Power Spectral Density

Given the BFSK signal set:
$$s_i(t) = \sqrt{\frac{2E_b}{T_b}} \cos(2\pi f_i t), \quad 0 \le t \le T_b, \quad f_i = \frac{n_c + i}{T_b}, \quad i \in \{1, 2\}$$

1. **Basis Functions:**
   Because $\Delta f = f_2 - f_1 = 1/T_b$, the signals are orthogonal over $[0, T_b]$: $\int_0^{T_b} s_1(t) s_2(t) dt = 0$.  
   The orthonormal basis is:
   $$\phi_1(t) = \sqrt{\frac{2}{T_b}} \cos(2\pi f_1 t), \quad \phi_2(t) = \sqrt{\frac{2}{T_b}} \cos(2\pi f_2 t)$$
   Signal vectors: $\mathbf{s}_1 = [\sqrt{E_b}, 0]^T, \; \mathbf{s}_2 = [0, \sqrt{E_b}]^T$ with $d_{\min} = \sqrt{2E_b}$.

2. **Baseband Equivalent Signal & Carrier Frequency:**
   Choosing carrier at the tone midpoint $f_c = \frac{n_c + 1.5}{T_b}$, the tone offsets are $f_{1,2} = f_c \mp \frac{1}{2T_b}$.  
   The complex baseband envelope $s_{i,\text{bb}}(t)$ satisfying $s_i(t) = \text{Re}\{s_{i,\text{bb}}(t) e^{j2\pi f_c t}\}$ is:
   $$s_{1,\text{bb}}(t) = \sqrt{\frac{2E_b}{T_b}} e^{-j \frac{\pi t}{T_b}}, \quad s_{2,\text{bb}}(t) = \sqrt{\frac{2E_b}{T_b}} e^{+j \frac{\pi t}{T_b}}, \quad 0 \le t \le T_b$$

3. **Bit Error Rate (BER):**
   $$P_{b,\text{BFSK}} = Q\left(\sqrt{\frac{E_b}{N_0}}\right) = \frac{1}{2}\text{erfc}\left(\sqrt{\frac{E_b}{2N_0}}\right)$$
   BFSK suffers a **$3.0\text{ dB}$ power penalty** relative to BPSK because $d_{\min}^2 = 2E_b$ compared to $4E_b$ for antipodal BPSK.

4. **Power Spectral Density (PSD):**
   Using the midpoint carrier, the baseband signal has continuous phase at bit transitions (Sunde's FSK, modulation index $h = \Delta f T_b = 1$). Its theoretical baseband PSD contains both discrete tone lines and a continuous envelope:
   $$S_{\text{bb}}(f) = \frac{E_b}{2T_b} \left[ \delta\left(f - \frac{1}{2T_b}\right) + \delta\left(f + \frac{1}{2T_b}\right) \right] + \frac{8E_b}{\pi^2} \frac{\cos^2(\pi f T_b)}{\left(1 - 4f^2 T_b^2\right)^2}$$
   - Discrete lines at $f = \pm 1/(2T_b)$ carry exactly half the total transmitted power.
   - The continuous component features spectral nulls at $f T_b = \pm 1.5, \pm 2.5, \dots$ and a steep $1/f^4$ sidelobe decay.

---

## 📊 Summary of Experimental Results

### Required $E_b/N_0$ for Target $\text{BER} = 10^{-4}$

| Modulation Scheme | Theoretical (dB) | Simulated (dB) | Absolute Deviation (dB) | Energy Penalty vs. BPSK |
| :--- | :---: | :---: | :---: | :---: |
| **BPSK** | 8.40 | 8.41 | **+0.01** | Reference (0 dB) |
| **QPSK (Gray)** | 8.40 | 8.35 | **-0.05** | 0.0 dB |
| **QPSK (Non-Gray)** | 8.63 | 8.51 | **-0.12** | +0.2 dB |
| **8-PSK** | 11.72 | 11.71 | **-0.01** | +3.3 dB |
| **16-QAM** | 12.20 | 12.20 | **0.00** | +3.8 dB |
| **BFSK (Coherent)** | 11.41 | 11.33 | **-0.08** | +3.0 dB |

### Simulated vs. Theoretical BER at Selected $E_b/N_0$ Points ($N = 1.2 \times 10^6$ bits)

| $E_b/N_0$ (dB) | BPSK (Sim / Theo) | QPSK (Sim / Theo) | 8-PSK (Sim / Theo) | 16-QAM (Sim / Theo) | BFSK (Sim / Theo) |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | 0.0787 / 0.0786 | 0.0788 / 0.0786 | 0.1229 / 0.1162 | 0.1407 / 0.1392 | 0.1589 / 0.1587 |
| **2** | 0.0372 / 0.0375 | 0.0377 / 0.0375 | 0.0805 / 0.0793 | 0.0971 / 0.0976 | 0.1039 / 0.1040 |
| **4** | 0.0126 / 0.0125 | 0.0126 / 0.0125 | 0.0459 / 0.0458 | 0.0589 / 0.0586 | 0.0565 / 0.0565 |
| **6** | 0.0023 / 0.0024 | 0.0024 / 0.0024 | 0.0205 / 0.0205 | 0.0280 / 0.0279 | 0.0231 / 0.0230 |
| **8** | 0.0002 / 0.0002 | 0.0002 / 0.0002 | 0.0062 / 0.0062 | 0.0091 / 0.0092 | 0.0060 / 0.0060 |
| **10** | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0010 / 0.0010 | 0.0017 / 0.0018 | 0.0008 / 0.0008 |
| **12** | 0.0000 / 0.0000 | 0.0000 / 0.0000 | 0.0001 / 0.0001 | 0.0001 / 0.0001 | 0.0000 / 0.0000 |

---

## 📂 Repository Directory Layout

```text
part1/
├── README.md                      # Comprehensive project documentation (this file)
│
├── specs/                         # Official project requirement specifications
│   └── Project part 1 2027.pdf
│
├── src/                           # MATLAB source code
│   ├── main.m                     # Master simulation script (runs all experiments and calls plots.m)
│   ├── plots.m                    # Master plotting script (generates all 7 figures & console tables)
│   ├── mapper.m                   # Symbol mapper for BPSK, QPSK, Non-Gray QPSK, 8PSK, 16-QAM, BFSK
│   ├── demapper.m                 # Matrix-vectorized Minimum Euclidean Distance ML detector
│   ├── awgn_channel.m             # Baseband AWGN channel generator strictly using randn
│   ├── theoretical_ber.m          # Analytical BER & tight bounds computed via erfc
│   ├── qpsk_gray_vs_nongray.m     # Dedicated simulation module for Task 2
│   ├── bfsk_analysis_psd.m        # Dedicated simulation module for Task 3 (BER + Welch PSD)
│   └── all_results_part1.mat      # Persisted simulation results for instant offline plotting
│
├── results/                       # High-resolution exported figures & simulation binaries
│   ├── all_results_part1.mat      # Simulation dataset
│   ├── Baseband AWGN BER Performance.png      # Combined BER curve (all schemes)
│   ├── QPSK Bit Mapping Comparison.png        # QPSK Gray vs. Non-Gray BER comparison
│   ├── Coherent Orthogonal BFSK BER.png       # BFSK BER vs. theoretical Q(sqrt(Eb/N0))
│   ├── Baseband Equivalent BFSK_PSD.png       # Welch PSD estimate vs. theoretical spectrum
│   ├── BFSK_baseband.png                      # Time-domain baseband in-phase & quadrature waveform
│   ├── Received_Constellations.png            # Noisy constellation snapshots at 5 dB and 15 dB
│   ├── BER_BPSK.png                           # Individual BPSK simulation vs. theory
│   ├── BER_QPSK.png                           # Individual QPSK simulation vs. theory
│   ├── BER_8PSK.png                           # Individual 8-PSK simulation vs. theory
│   ├── BER_16QAM.png                          # Individual 16-QAM simulation vs. theory
│   └── results.png                            # Numerical verification summary table
│
└── report/                        # Final academic report
    └── Single-Carrier Digital Modulation.pdf  # Complete 21-page report with IEEE citations
```

---

## 🚀 How to Run the Code

### Requirements
- **MATLAB** (R2021a or newer recommended) or **GNU Octave**.
- No specialized toolboxes required (self-contained using built-in `erfc`).

### Quick Start
1. Open MATLAB and navigate to the `src` folder:
   ```matlab
   cd 'D:/EECE 5/Advanced Communication Systems/Projects/part1/src'
   ```
2. **To re-run the full simulation from scratch:**
   ```matlab
   main
   ```
   *Runs all Monte Carlo loops, updates `all_results_part1.mat`, and displays all verification tables and figures.*

3. **To re-plot figures instantly without waiting for simulation:**
   ```matlab
   plots
   ```
   *Immediately loads `all_results_part1.mat` and renders all seven analytical figures.*
