# Digital Communications Projects - EECE 3rd Year

**Cairo University — Faculty of Engineering**  
**Electronics and Communications Engineering Department (EECE)**  
**Course:** Digital Communications / Advanced Communication Systems  
**Academic Year:** 2026/2027  
**Submission Deadline:** 14 December 2026, 11:59 PM  

---

## 📌 Repository Overview

This repository is organized to facilitate collaborative development across the **3 course projects** for our team. Each project part has a standardized workspace and a dedicated Git branch, allowing team members to independently develop code, run simulations, save figures/results, and write reports without conflicts.

---

## 👥 Team & Project Allocation

| Project Part | Description / Focus | Branch | Owner / Lead |
| :--- | :--- | :--- | :--- |
| **Part 1** | Single Carrier Modulation & BER Performance (BPSK, QPSK, 8PSK, 16-QAM, BFSK under AWGN) | `part-1` | Adham |
| **Part 2** | Project Part 2 *(Specs to be added)* | `part-2` | Team Member 2 |
| **Part 3** | Project Part 3 *(Specs to be added)* | `part-3` | Team Member 3 |

---

## 📁 Repository Directory Structure

```text
Digital_Comm/
├── .gitignore               # Ignores MATLAB temp/cache, Python virtualenvs, LaTeX builds
├── README.md                # Main repository overview & collaboration guide
│
├── part1/                   # Project Part 1 (Single Carrier Modulation & BER)
│   ├── README.md            # Detailed specs, theory, constellation mappings & task checklist
│   ├── specs/               # Official PDF requirements ("Project part 1 2027.pdf")
│   ├── src/                 # Simulation code (MATLAB .m scripts & helper functions)
│   ├── results/             # Generated BER curves, PSD plots, figures (.png, .fig, .mat)
│   └── report/              # Final report (PDF, LaTeX source, figures)
│
├── part2/                   # Project Part 2
│   ├── README.md            # Project 2 guidelines & task description
│   ├── specs/               # Specification sheets & guidelines
│   ├── src/                 # Implementation source code
│   ├── results/             # Simulation results & plots
│   └── report/              # Deliverable report
│
└── part3/                   # Project Part 3
    ├── README.md            # Project 3 guidelines & task description
    ├── specs/               # Specification sheets & guidelines
    ├── src/                 # Implementation source code
    ├── results/             # Simulation results & plots
    └── report/              # Deliverable report
```

---

## 🌿 Git Branching Workflow

To keep code reviews clean and avoid merge conflicts:

### 1. Working on your Assigned Part
Each member works directly in their designated branch:
```bash
# Switch to your project branch (example for Part 1):
git checkout part-1

# Verify current branch:
git branch
```

### 2. Saving and Pushing Progress
When you finish writing code, generating plots, or updating the report:
```bash
# Stage your changes:
git add part1/

# Commit with a descriptive message:
git commit -m "Implement BPSK & QPSK Monte Carlo simulation and theoretical curves"

# Push to GitHub:
git push -u origin part-1
```

### 3. Merging into `main`
Once a project part is fully tested, verified, and its report is completed:
1. Create a Pull Request (PR) from `part-X` into `main` on GitHub: [Digital_Comm Pull Requests](https://github.com/Euro-max/Digital_Comm/pulls).
2. Review with the team and merge into `main`.

---

## 🛠️ Tools & Prerequisites
- **MATLAB** (R2021a or newer recommended) / **GNU Octave** / **Python 3.10+** (NumPy, SciPy, Matplotlib)
- **Git**
