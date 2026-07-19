# Clock Domain Crossing (CDC) Verification using Verilog

## Overview

This repository presents the **RTL design and functional verification** of fundamental **Clock Domain Crossing (CDC)** techniques using **Verilog HDL**. The project demonstrates reliable data transfer between asynchronous clock domains through industry-standard synchronization techniques and comprehensive self-checking verification.

Each module has been independently designed, simulated, and verified using **Xilinx Vivado XSim**, with dedicated testbenches, waveform analysis, and automated PASS/FAIL reporting.

---

## Implemented CDC Modules

### Two Flip-Flop (2FF) Synchronizer
- Synchronizes single-bit control signals across asynchronous clock domains
- Mitigates metastability using a two-stage flip-flop architecture
- Verified under multiple clock frequency ratios

### Pulse Synchronizer
- Transfers single-cycle pulses safely between asynchronous clock domains
- Toggle-based implementation to prevent pulse loss
- Verified using randomized and stress test scenarios

### Toggle Synchronizer
- Synchronizes toggle events across different clock domains
- Generates a clean pulse in the destination domain
- Tested with multiple clock ratios and random toggle sequences

### Reset Synchronizer
- Implements asynchronous assertion and synchronous deassertion of reset
- Parameterized synchronization stages
- Verified across multiple independent clock domains

### Handshake Synchronizer
- Reliable request/acknowledge communication between asynchronous clock domains
- Supports Fast-to-Slow and Slow-to-Fast clock crossings
- Verified using randomized transaction-based testing

---

## Verification Methodology

Each module is verified using a dedicated **self-checking Verilog testbench** featuring:

- Automatic PASS/FAIL reporting
- Randomized stimulus generation
- Multiple asynchronous clock scenarios
- Functional correctness verification
- Reset validation
- Waveform analysis
- Simulation result summary

---

## Project Structure

```text
Clock-Domain-Crossing-CDC-Verification/
│
├── rtl/
│   ├── sync_2ff.v
│   ├── pulse_sync.v
│   ├── toggle_sync.v
│   ├── reset_sync.v
│   └── handshake_sync.v
│
├── tb/
│   ├── tb_sync_2ff.v
│   ├── tb_pulse_sync.v
│   ├── tb_toggle_sync.v
│   ├── tb_reset_sync.v
│   └── tb_handshake_sync.v
│
├── docs/
│   ├── waveforms/
│   └── testcases pass/
│
└── README.md
```

---

## Tools Used

- Verilog HDL
- Xilinx Vivado
- Vivado XSim
- Digital Logic Design

---

## Technologies & Skills

- Verilog HDL
- RTL Design
- Functional Verification
- Design Verification (DV)
- Clock Domain Crossing (CDC)
- Metastability Mitigation
- Two Flip-Flop Synchronizer
- Pulse Synchronizer
- Toggle Synchronizer
- Reset Synchronizer
- Handshake Synchronizer
- Self-Checking Testbench
- Simulation & Debugging
- Waveform Analysis
- Digital Logic Design
- Xilinx Vivado

---

## Verification Results

All implemented CDC modules were successfully verified using self-checking testbenches.

- ✔ Functional Verification Passed
- ✔ Randomized Test Cases Passed
- ✔ Multiple Clock Domain Scenarios Verified
- ✔ Waveform Validation Completed
- ✔ Simulation Completed Successfully

---

## Applications

- ASIC Design Verification
- FPGA Design
- Clock Domain Crossing (CDC)
- Digital VLSI Design
- High-Speed Digital Systems
- SoC Design

---

## Future Enhancements

- SystemVerilog-based Verification
- Assertion-Based Verification (SVA)
- Functional Coverage
- UVM Testbench Development
- Multi-bit CDC Verification

---

## Author

**Snehanjali Dasari**

**Aspiring Design Verification Engineer**
