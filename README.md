# Synthesizable UART Controller with Cocotb Verification Suite

A fully synthesizable, full-duplex UART (Universal Asynchronous Receiver-Transmitter) controller implemented in SystemVerilog (IEEE 1800-2012) and verified using an event-driven Python testbench with **Cocotb** and **Icarus Verilog**.

## Key Specifications & Features

* **System Clock / Baud Rate**: 50 MHz system clock with standard 115,200 Baud rate (8-N-1 framing style).
* **Clock Divider (`baud_gen.sv`)**: Independent counter architecture generating 1x baud strobes for transmission and 16x oversampling strobes for receiver synchronization.
* **Transmitter (`uart_tx.sv`)**: FSM-driven serializer handling start bit generation, serial right-shifting of 8 data bits (LSB-first), and stop bit assertion with `tx_ready` flow control.
* **Receiver (`uart_rx.sv`)**: Features a 2-flip-flop synchronizer against metastability, false-start glitch filtering, and robust mid-bit sampling logic (at 7th and 15th oversampling ticks).
* **Top-Level Integration (`uart_top.sv`)**: Clean structural top-level module connecting sub-modules with standard streaming data interfaces.

## System Topography

```
                     +---------------+
tx_din / tx_en ----->|    uart_tx    |---------> tx ---+
                     +---------------+                 |
                            ^                          | (Hardware Loopback)
clk, reset --------->|   baud_gen    |                 |
                            v                          |
                     +---------------+                 |
rx_data / rx_valid <-|    uart_rx    |<--------- rx <--+
                     +---------------+
```
## Verification Environment (`test_uart.py`)

Automated self-checking loopback regression testsuite using **Cocotb**:
* Dynamic background task mapping `dut.rx` to `dut.tx` during clock edges.
* Comprehensive frame tests for edge cases (`0x00`, `0xFF`, `0x55`, `0xA5`) and random payloads.
* Timeout-protected verification (`with_timeout`) ensuring strict frame latency guarantees.

## Quick Start & Execution

### Prerequisites
* Linux / WSL2 (Ubuntu)
* Icarus Verilog (`iverilog >= 12.0`)
* Python 3.10+ with `cocotb`

### Run Test Suite
make clean && make
