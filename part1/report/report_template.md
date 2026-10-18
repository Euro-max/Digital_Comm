# Project Part 1: Single Carrier Modulation & BER Performance
## Course: Digital Communications / Advanced Communication Systems
**Cairo University — Faculty of Engineering**  
**Electronics and Communications Engineering Department (EECE 3rd Year)**  

**Author:** Adham  
**Academic Year:** 2026/2027  
**Submission Due Date:** 14 December 2026, 11:59 PM  

---

## Abstract
Briefly summarize the objective of the project, the simulated communication chain (mapper, AWGN channel, demapper), the modulation schemes investigated (BPSK, QPSK, 8PSK, 16-QAM, BFSK), key findings regarding Gray vs. Non-Gray coding, and the spectral properties of BFSK.

---

## 1. Introduction & System Model
- Diagram of the baseband equivalent single-carrier communication system:
  $$\text{Data Bits} \longrightarrow \text{Symbol Mapper} \longrightarrow \text{AWGN Channel} \longrightarrow \text{Demapper / Detector} \longrightarrow \text{BER Calculator}$$
- Baseband equivalent representation:
  - Explain why no RF carrier is simulated in baseband equivalence.
  - Channel model: $r = s + n$, where $n \sim \mathcal{CN}(0, N_0)$.
  - Implementation in MATLAB using `randn`:
    $$n = \sqrt{\frac{N_0}{2}} \cdot (\text{randn} + j \cdot \text{randn})$$

---

## 2. Modulation Schemes & Constellation Mappings
### 2.1 BPSK ($M=2$, $k=1$ bit/symbol)
- Mapping rule: $b_0 = 0 \to -r$, $b_0 = 1 \to +r$.
- Exact theoretical BER: $P_b = Q\left(\sqrt{\frac{2E_b}{N_0}}\right)$.

### 2.2 QPSK ($M=4$, $k=2$ bits/symbol)
- **Gray Coded (Figure 2):**
  - Mappings: $01 \to (-r, +r)$, $11 \to (+r, +r)$, $00 \to (-r, -r)$, $10 \to (+r, -r)$.
  - Nearest neighbor transitions result in only 1 bit error.
  - Theoretical BER: $P_b = Q\left(\sqrt{\frac{2E_b}{N_0}}\right)$.
- **Non-Gray Coded (Figure 3):**
  - Mappings: $01 \to (-r, +r)$, $10 \to (+r, +r)$, $00 \to (-r, -r)$, $11 \to (+r, -r)$.
  - Nearest neighbor transitions between $(01)$ and $(10)$ result in 2 bit errors.

### 2.3 8-PSK ($M=8$, $k=3$ bits/symbol)
- Gray coded constellation on circle of radius $r$.
- Tight upper bound / high SNR approximation:
  $$P_b \approx \frac{2}{3} Q\left(\sqrt{\frac{2E_s}{N_0}} \sin\left(\frac{\pi}{8}\right)\right)$$

### 2.4 16-QAM ($M=16$, $k=4$ bits/symbol)
- Rectangular grid constellation on $I, Q \in \{-3, -1, +1, +3\}$.
- Theoretical BER:
  $$P_b \approx \frac{3}{8} Q\left(\sqrt{\frac{4}{5} \frac{E_b}{N_0}}\right)$$

---

## 3. BFSK Signal Analysis (Section 1.5)

### 3.1 Basis Functions of the Signal Set
Given:
$$s_i(t) = \sqrt{\frac{2E_b}{T_b}} \cos(2\pi f_i t), \quad 0 \le t \le T_b, \quad i \in \{1, 2\}$$
with $f_i = \frac{n_c + i}{T_b}$.
Since $f_2 - f_1 = \frac{1}{T_b}$, $\int_0^{T_b} s_1(t) s_2(t) dt = 0$.
The two orthonormal basis functions are:
$$\phi_1(t) = \sqrt{\frac{2}{T_b}} \cos(2\pi f_1 t), \quad 0 \le t \le T_b$$
$$\phi_2(t) = \sqrt{\frac{2}{T_b}} \cos(2\pi f_2 t), \quad 0 \le t \le T_b$$
Signal space coordinates:
$$\mathbf{s}_1 = \begin{bmatrix} \sqrt{E_b} \\ 0 \end{bmatrix}, \quad \mathbf{s}_2 = \begin{bmatrix} 0 \\ \sqrt{E_b} \end{bmatrix}$$
Distance: $d = \sqrt{2E_b}$.

### 3.2 Baseband Equivalent Signals & Chosen Carrier Frequency
Choosing the nominal carrier frequency as the center frequency:
$$f_c = \frac{f_1 + f_2}{2} = \frac{n_c + 1.5}{T_b}$$
Then:
$$f_1 = f_c - \frac{1}{2T_b}, \quad f_2 = f_c + \frac{1}{2T_b}$$
The passband signal relates to the complex baseband envelope $v_i(t)$ by:
$$s_i(t) = \text{Re}\{ v_i(t) e^{j 2\pi f_c t} \}$$
Therefore, the baseband equivalent signals are:
$$v_1(t) = \sqrt{\frac{2E_b}{T_b}} e^{-j \frac{\pi t}{T_b}}, \quad 0 \le t \le T_b$$
$$v_2(t) = \sqrt{\frac{2E_b}{T_b}} e^{+j \frac{\pi t}{T_b}}, \quad 0 \le t \le T_b$$

---

## 4. Simulation Results & Discussion

### 4.1 Task 1: Multi-Modulation Comparison (BPSK, QPSK, 8PSK, 16-QAM)
*(Insert figure: `../results/task1_ber_comparison.png`)*
- Discussion:
  - BPSK and QPSK share the exact same BER performance as a function of $E_b/N_0$ because QPSK can be viewed as two orthogonal BPSK channels on $I$ and $Q$.
  - 8PSK and 16-QAM require higher $E_b/N_0$ to achieve the same BER due to reduced Euclidean distance between constellation points for a fixed energy.
  - Spectral efficiency vs. power efficiency tradeoff.

### 4.2 Task 2: QPSK Gray vs. Non-Gray Mapping (Fig 2 vs. Fig 3)
*(Insert figure: `../results/task2_qpsk_comparison.png`)*
- Discussion:
  - Symbol error rates are identical for both mappings.
  - Gray coding guarantees that nearest-neighbor symbol errors produce only 1 bit error.
  - Non-Gray mapping produces 2 bit errors for transitions between $(01)$ and $(10)$, increasing BER by a factor close to 1.5 to 2 at high SNR.

### 4.3 Task 3: BFSK BER and Power Spectral Density
*(Insert figures: `../results/task3_bfsk_ber.png` and `../results/task3_bfsk_psd.png`)*
- Discussion on BFSK BER matching $Q(\sqrt{E_b/N_0})$ (3 dB power penalty relative to BPSK).
- Discussion on baseband PSD and main lobe bandwidth.

---

## 5. Conclusion
Summary of the project results and practical lessons learned from single-carrier baseband simulation.
