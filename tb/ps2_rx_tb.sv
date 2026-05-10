// =============================================================================
// Module  : ps2_rx_tb
// Purpose : Basic testbench for ps2_rx.sv
// Group   : B (PS/2)
// Week    : 1 — DV Ramp Up | Asmicore Semiconductor
// Status  : INCOMPLETE — See issue_log.txt ISSUE-005
// =============================================================================
// What works:
//   - Clock and reset generation
//   - Task to drive one PS/2 byte serially
//   - TC001: normal byte (0x1C = letter A scan code)
// What is missing:
//   - TC002 reset boundary test
//   - TC003 no-start-bit test
//   - Parity verification
// =============================================================================

`timescale 1ns/1ps

module ps2_rx_tb;

    // ── DUT ports ────────────────────────────────────────────────────────
    logic        clk;
    logic        rst;
    logic        ps2_clk;
    logic        ps2_data;
    logic [7:0]  rx_data;
    logic        rx_valid;

    // ── DUT instantiation ────────────────────────────────────────────────
    ps2_rx dut (
        .clk      (clk),
        .rst      (rst),
        .ps2_clk  (ps2_clk),
        .ps2_data (ps2_data),
        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );

    // ── System clock: 50 MHz (20 ns period) ─────────────────────────────
    initial clk = 0;
    always #10 clk = ~clk;

    // ── PS/2 clock: ~10 kHz (slow, 50 µs half-period in sim units) ──────
    // Using 500ns half-period here for faster simulation
    parameter PS2_HALF = 500;

    // ── Task: send one PS/2 byte ─────────────────────────────────────────
    // Sends: start(0), D0..D7 (LSB first), odd parity, stop(1)
    task automatic send_ps2_byte(input [7:0] data);
        integer i;
        logic parity;
        parity = ^data;         // even parity of data bits
        parity = ~parity;       // invert → odd parity

        // Start bit
        ps2_data = 1'b0;
        #PS2_HALF; ps2_clk = 0;
        #PS2_HALF; ps2_clk = 1;

        // 8 data bits — LSB first
        for (i = 0; i < 8; i++) begin
            ps2_data = data[i];
            #PS2_HALF; ps2_clk = 0;
            #PS2_HALF; ps2_clk = 1;
        end

        // Parity bit
        ps2_data = parity;
        #PS2_HALF; ps2_clk = 0;
        #PS2_HALF; ps2_clk = 1;

        // Stop bit
        ps2_data = 1'b1;
        #PS2_HALF; ps2_clk = 0;
        #PS2_HALF; ps2_clk = 1;

        // Small gap before next frame
        #(PS2_HALF * 4);
    endtask

    // ── Stimulus ─────────────────────────────────────────────────────────
    initial begin
        $display("========================================");
        $display("  PS/2 RX Testbench — Group B | Week 1");
        $display("  Status: PARTIAL (see ISSUE-005)");
        $display("========================================");

        // Initialise
        ps2_clk  = 1'b1;
        ps2_data = 1'b1;
        rst      = 1'b1;

        // Apply reset for 4 clock cycles
        repeat(4) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        // ── TC001: Normal byte — 0x1C (letter A scan code) ──────────────
        $display("[TC001] Sending 0x1C (letter A) ...");
        send_ps2_byte(8'h1C);

        // Wait for rx_valid to pulse
        @(posedge rx_valid);
        if (rx_data === 8'h1C)
            $display("[PASS] TC001 | rx_data=0x%02X  expected=0x1C", rx_data);
        else
            $display("[FAIL] TC001 | rx_data=0x%02X  expected=0x1C", rx_data);

        // ── TC002 & TC003: Not yet implemented (ISSUE-005) ───────────────
        $display("[SKIP] TC002 — reset boundary test (not implemented)");
        $display("[SKIP] TC003 — no-start-bit test (not implemented)");

        $display("========================================");
        $finish;
    end

    // ── Waveform dump ────────────────────────────────────────────────────
    initial begin
        $dumpfile("waves/ps2_rx_tb.vcd");
        $dumpvars(0, ps2_rx_tb);
    end

endmodule
