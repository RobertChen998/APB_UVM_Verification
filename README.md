# APB UVM Verification

This project is a SystemVerilog UVM testbench for an APB slave. It checks protocol timing, data correctness, illegal address handling, and reset behavior.

## Included

- APB interface with assertions
- UVM sequence, driver, monitor, agent, and scoreboard
- Write/read/random test scenarios
- Coverage tracking and result checking
- Random delay modeling in DUT

## Structure

```text
APB_UVM_Verification/
├── tb/
│   ├── tb_top.sv
│   ├── transaction.sv
│   ├── sequence.sv
│   ├── apb_if.sv
│   ├── apb_driver.sv
│   ├── apb_monitor.sv
│   ├── apb_agent.sv
│   ├── apb_scoreboard.sv
│   ├── apb_env.sv
│   ├── apb_test.sv
│   └── apb_sequencer.sv
├── dut.sv
├── regression.tcl
└── README.md
```

## Run

Use the Vivado simulation flow and run tcl from `regression.tcl`.

```systemverilog
source regression.tcl;
```

This project is intended for APB protocol verification and UVM learning practice.