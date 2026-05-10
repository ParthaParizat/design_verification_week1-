// =============================================================================
// Module  : alu_tb
// Purpose : Basic testbench for alu.sv
// Group   : B (PS/2)
// Week    : 1 — DV Ramp Up | Asmicore Semiconductor
// =============================================================================
// Testcases driven:
//   TC001 — ADD  normal
//   TC002 — ADD  boundary (overflow)
//   TC003 — SUB  normal
//   TC004 — SUB  boundary (underflow)
//   TC005 — AND  normal
//   TC006 — DIV  invalid (divide-by-zero)
//   TC007 — DIV  normal
//   TC008 — XOR  normal
// =============================================================================

`timescale 1ns/1ps

module alu_tb;

    // ── DUT ports ────────────────────────────────────────────────────────
    logic [7:0]  a, b;
    logic [2:0]  opcode;
    logic [7:0]  result;
    logic        zero_flag;
    logic        overflow_flag;

    // ── DUT instantiation ────────────────────────────────────────────────
    alu dut (
        .a             (a),
        .b             (b),
        .opcode        (opcode),
        .result        (result),
        .zero_flag     (zero_flag),
        .overflow_flag (overflow_flag)
    );

    // ── Counters ─────────────────────────────────────────────────────────
    int pass_count = 0;
    int fail_count = 0;

    // ── Task: apply stimulus and check output ────────────────────────────
    task automatic apply_and_check(
        input [7:0]  in_a,
        input [7:0]  in_b,
        input [2:0]  op,
        input [7:0]  expected,
        input string tc_id
    );
        a      = in_a;
        b      = in_b;
        opcode = op;
        #10;    // let combinational logic settle

        if (result === expected) begin
            $display("[PASS] %s | op=%03b  a=%3d  b=%3d | result=%3d",
                     tc_id, op, in_a, in_b, result);
            pass_count++;
        end else begin
            $display("[FAIL] %s | op=%03b  a=%3d  b=%3d | expected=%3d  got=%3d",
                     tc_id, op, in_a, in_b, expected, result);
            fail_count++;
        end
    endtask

    // ── Stimulus ─────────────────────────────────────────────────────────
    initial begin
        $display("========================================");
        $display("  ALU Testbench — Group B | Week 1");
        $display("========================================");

        // Initialise
        a = 0; b = 0; opcode = 0;
        #5;

        // Normal tests
        apply_and_check(8'd10,   8'd5,    3'b000, 8'd15,  "TC001");   // ADD normal
        apply_and_check(8'd200,  8'd100,  3'b000, 8'd44,  "TC002");   // ADD overflow wraps
        apply_and_check(8'd10,   8'd10,   3'b001, 8'd0,   "TC003");   // SUB normal
        apply_and_check(8'd0,    8'd5,    3'b001, 8'd251, "TC004");   // SUB underflow
        apply_and_check(8'hAA,   8'h55,   3'b010, 8'h00,  "TC005");   // AND
        apply_and_check(8'd10,   8'd0,    3'b110, 8'hFF,  "TC006");   // DIV by zero
        apply_and_check(8'd10,   8'd2,    3'b110, 8'd5,   "TC007");   // DIV normal
        apply_and_check(8'hFF,   8'hFF,   3'b100, 8'h00,  "TC008");   // XOR

        $display("----------------------------------------");
        $display("  TOTAL: %0d  |  PASS: %0d  |  FAIL: %0d",
                 pass_count + fail_count, pass_count, fail_count);
        $display("========================================");

        $finish;
    end

    // ── Optional: dump waveform ──────────────────────────────────────────
    initial begin
        $dumpfile("waves/alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule
