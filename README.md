# CHERI RISC-V Capability Width CPI Study

This project investigates where the performance overhead of 128-bit CHERI capabilities actually comes from, and implements a lightweight RTL-level compression mechanism to reduce memory-bound workloads.

## Summary
- Implemented a 32-bit RISC-V core with CHERI-style widened capability.
- Evaluated the CPI behaviour across different memory-pressure using gem5.
- Shows that performance divergence emerge appears once workloads exceed cache capacity.
- Explores a mantissa truncation mechanism to rreduce memory-bound workloads.

> Note: Synthesis results (Yosys/Vivado sanity check) show no LUT change across configurations, consistent with an architectural-level modification that primarily affects memory behavior rather than control logic.

## Repository Structure
- `rtl/` : RTL of the capability-aware RISC-V core and mitigation modules
- `gem5/` : gem5 configs/workloads and raw outputs
- `scripts/` : run scripts and plotting utilities
- `data/` : processed CSV files used for plots
- `results/figures/` : final figures used in the poster
- `docs/diagrams/` : datapath diagrams and notes

