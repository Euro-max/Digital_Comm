# Project Part 1: Single Carrier Modulation & BER Performance

**Course:** Digital Communications / Advanced Communication Systems  
**Institution:** Cairo University — Faculty of Engineering, EECE Dept. (3rd Year)  
**Due Date:** 14 December 2026, 11:59 PM  
**Assigned Lead:** Adham  
**Branch:** `part-1`  

---

## 🎯 Purpose & Scope

The purpose of this project is to simulate and analyze a single-carrier digital communication system over an Additive White Gaussian Noise (AWGN) channel at baseband. We investigate symbol mapping, detection, bit error rate (BER) performance across various digital modulation schemes, and power spectral density (PSD).

```
+------------+       +------------+       +------------+       +--------------+       +----------------+
| Data Bits  | ----> |   Mapper   | ----> |    AWGN    | ----> |   Demapper   | ----> | BER Calculator |
|   {0, 1}   |       | (Baseband) |       |  Channel   |       | (ML Detector)|       |  (Sim vs Theo) |
+------------+       +------------+       +------------+       +--------------+       +----------------+
```

---

## 📡 Modulation Schemes Under Study

All simulations are performed using the **baseband equivalent model** (no RF carriers):

1. **BPSK ($M=2$, $k=1$ bit/symbol):**
   - Constellation: $0 \to -r$, $1 \to +r$, where $r = \sqrt{E_b}$.
   - Theoretical BER: $P_b = Q\left(\sqrt{\frac{2E_b}{N_0}}\right)$.

2. **QPSK ($M=4$, $k=2$ bits/symbol):**
   - **Figure 2 (Gray Coded):**
     - `01` $\to (-r, +r)$
     - `11` $\to (+r, +r)$
     - `00` $\to (-r, -r)$
     - `10` $\to (+r, -r)$
     - Adjacent constellation points differ by only 1 bit.
   - **Figure 3 (Non-Gray Coded):**
     - `01` $\to (-r, +r)$
     - `10` $\to (+r, +r)$ *(Differs by 2 bits from `01`!)*
     - `00` $\to (-r, -r)$
     - `11` $\to (+r, -r)$

3. **8PSK ($M=8$, $k=3$ bits/symbol):**
   - Constellation: 8 points on a circle of radius $r = \sqrt{E_s} = \sqrt{3E_b}$, Gray coded as specified in Figure 2:
     - `000` at $(r, 0)$
     - `001` at $(r/\sqrt{2}, r/\sqrt{2})$
     - `011` at $(0, r)$
     - `010` at $(-r/\sqrt{2}, r/\sqrt{2})$
     - `110` at $(-r, 0)$
     - `111` at $(-r/\sqrt{2}, -r/\sqrt{2})$
     - `101` at $(0, -r)$
     - `100` at $(r/\sqrt{2}, -r/\sqrt{2})$
   - Theoretical BER (approximate / tight bound):
     $$P_b \approx \frac{2}{3} Q\left(\sqrt{\frac{2E_s}{N_0}} \sin\left(\frac{\pi}{8}\right)\right)$$

4. **16-QAM ($M=16$, $k=4$ bits/symbol):**
   - Rectangular grid on $I, Q \in \{-3, -1, +1, +3\} \times d$, Gray coded as specified in Figure 2.
   - Theoretical BER:
     $$P_b \approx \frac{3}{8} Q\left(\sqrt{\frac{4}{5} \frac{E_b}{N_0}}\right)$$

5. **BFSK (Binary Frequency Shift Keying):**
   - Transmitted signal:
     $$s_i(t) = \sqrt{\frac{2E_b}{T_b}} \cos(2\pi f_i t), \quad 0 \le t \le T_b, \quad i \in \{1, 2\}$$
     where $f_i = \frac{n_c + i}{T_b}$.
   - Minimum frequency separation $\Delta f = \frac{1}{T_b}$ ensures coherent orthogonality.
   - Theoretical BER (Coherent detection):
     $$P_b = Q\left(\sqrt{\frac{E_b}{N_0}}\right)$$

---

## 📋 Required Tasks Checklist

- [ ] **Task 1: BER vs. $E_b/N_0$ Multi-Modulation Comparison**
  - Simulate BPSK, QPSK, 8PSK, and 16-QAM across an $E_b/N_0$ range (e.g., $0$ to $14\text{ dB}$).
  - Plot Monte Carlo simulated BER alongside theoretical curves (or tight upper bounds) on a single semilogy plot.
  - Provide technical discussion and commentary on spectral efficiency vs. energy efficiency tradeoffs.

- [ ] **Task 2: QPSK Gray vs. Non-Gray Mapping Comparison**
  - Simulate the Gray-coded QPSK (Figure 2) and non-Gray coded QPSK (Figure 3).
  - Plot both BER curves on the same semilogy graph.
  - Explain the impact of mapping on bit error rate when symbol errors occur between nearest neighbors.

- [ ] **Task 3: BFSK Signal Analysis & Simulation**
  - **Basis Functions:** Derive and state orthonormal basis functions $\phi_1(t), \phi_2(t)$.
  - **Baseband Equivalent:** Write analytical mathematical expression for the complex envelope / baseband equivalent signals and identify the chosen carrier frequency.
  - **BER Curve:** Simulate BFSK over AWGN and compare with theoretical $P_b = Q(\sqrt{E_b/N_0})$.
  - **Baseband PSD:** Simulate and plot the Power Spectral Density of the baseband equivalent signal.

- [ ] **Task 4: Final Documentation & Deliverables**
  - Complete report addressing all theoretical questions, mathematical derivations, graphs, and commentary.
  - Clean, commented simulation scripts in `src/`.
  - High-resolution figures saved in `results/`.

---

## 📂 Subdirectory Organization

```text
part1/
├── README.md               # This specification guide
├── specs/
│   └── Project part 1 2027.pdf
├── src/                    # MATLAB scripts & functions
│   ├── main_modulation_ber.m   # Task 1 simulation driver
│   ├── qpsk_gray_vs_nongray.m  # Task 2 simulation driver
│   ├── bfsk_analysis_psd.m     # Task 3 BFSK BER & PSD driver
│   ├── mapper.m                # Constellation mapper
│   ├── demapper.m              # Maximum Likelihood symbol demapper
│   ├── awgn_channel.m          # Noise generation using randn
│   └── theoretical_ber.m       # Theoretical formulas & bounds
├── results/                # Exported figures (.png, .fig)
└── report/                 # Report document (LaTeX / Word / PDF)
```
