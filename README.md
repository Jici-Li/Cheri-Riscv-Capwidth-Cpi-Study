# CHERI RISC-V Capability Width CPI Study

This repository contains a small project studying the **system-level performance overheads of widened CHERI-style capabilities (e.g.,128-bit)** and a lightweight architectural mitigation.

## Summary
- Implemented a **32-bit RISC-V** core.
- Evaluated the overhead of widened capabilities using **gem5**, focusing on **CPI** and cache/memory-pressure regimes.
- Explored a **fixed-latency write-back stage truncation / bit-masking** mechanism to reshape the memory traffic overhead.
- Observed an average CPI reduction of **~9.54%** in memory-intensive regimes (project-specific workloads).

> Note: Synthesis results (Yosys/Vivado sanity check) show no LUT change across configurations, consistent with an architectural-level modification that primarily affects memory behavior rather than control logic.

## Repository Structure
- `rtl/` : RTL of the capability-aware RISC-V core and mitigation modules
- `gem5/` : gem5 configs/workloads and raw outputs
- `scripts/` : run scripts and plotting utilities
- `data/` : processed CSV files used for plots
- `results/figures/` : final figures used in the poster
- `docs/diagrams/` : datapath diagrams and notes

