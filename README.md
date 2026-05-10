# DV Ramp Up — Week 1
**Group B | PS/2 Protocol**
Asmicore Semiconductor — DV Team

---

## Overview

This repository contains the Week-1 work for Group B of the Asmicore DV Ramp Up program.
The assigned protocol is **PS/2**. All groups also complete a shared ALU design task.

---

## Repository Structure

```
dv-ramp-up-week1/
│
├── rtl/
│   ├── alu.sv              — Complete 8-bit ALU (all 7 operations)
│   └── ps2_rx.sv           — PS/2 serial receiver (FSM-based)
│
├── tb/
│   ├── alu_tb.sv           — ALU testbench (8 testcases, all passing)
│   └── ps2_rx_tb.sv        — PS/2 testbench (partial — see ISSUE-005)
│
├── testcases/
│   ├── alu_tests.json      — Structured ALU testcase definitions
│   └── protocol_tests.json — PS/2 testcase definitions
│
├── outputs/
│   ├── day1_design.json    — Day 1: basic ALU design info
│   ├── day2_signals.json   — Day 2: PS/2 signal and frame structure
│   ├── day3_logic.json     — Day 3: complete ALU operations and signals
│   ├── day4_protocol.json  — Day 4: opcode map and verification thinking
│   ├── day5_testplan.json  — Day 5: full test plan (ALU + PS/2)
│   └── day6_results.json   — Day 6: simulation results
│
├── waves/                  — VCD waveform dumps (generated during simulation)
│
├── logs/
│   └── issue_log.txt       — All issues encountered, with status
│
└── README.md
```

---

## What Was Done

| Day | Topic                          | Status  |
|-----|-------------------------------|---------|
| 1   | ALU basics + Git setup         | Done    |
| 2   | PS/2 protocol understanding    | Done    |
| 3   | Complete ALU + signal docs     | Done    |
| 4   | Verification thinking + plan   | Done    |
| 5   | PS/2 RTL + testcase JSON       | Done    |
| 6   | ALU testbench                  | Done    |

---

## Simulation Results (ALU)

| TC    | Operation | A   | B   | Expected | Result |
|-------|-----------|-----|-----|----------|--------|
| TC001 | ADD       | 10  | 5   | 15       | PASS   |
| TC002 | ADD       | 200 | 100 | 44       | PASS   |
| TC003 | SUB       | 10  | 10  | 0        | PASS   |
| TC004 | SUB       | 0   | 5   | 251      | PASS   |
| TC005 | AND       | 0xAA| 0x55| 0x00    | PASS   |
| TC006 | DIV       | 10  | 0   | 0xFF     | PASS   |
| TC007 | DIV       | 10  | 2   | 5        | PASS   |
| TC008 | XOR       | 0xFF| 0xFF| 0x00    | PASS   |

**8/8 PASS**

---

## How to Run (EDAPlayground / Icarus Verilog)

```bash
# ALU
iverilog -g2012 -o alu_sim rtl/alu.sv tb/alu_tb.sv
vvp alu_sim

# PS/2 (partial)
iverilog -g2012 -o ps2_sim rtl/ps2_rx.sv tb/ps2_rx_tb.sv
vvp ps2_sim
```

---

## Open Issues

| ID        | Description                           | Status |
|-----------|---------------------------------------|--------|
| ISSUE-001 | SSH key setup for GitHub              | RESOLVED |
| ISSUE-002 | overflow_flag not implemented         | OPEN   |
| ISSUE-003 | PS/2 parity check not implemented     | OPEN   |
| ISSUE-004 | No debounce on ps2_clk                | OPEN   |
| ISSUE-005 | PS/2 testbench incomplete             | OPEN   |

See `logs/issue_log.txt` for full details.

---

*Week 1 | Group B — Asmicore Semiconductor DV Team*
