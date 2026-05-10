// =============================================================================
// Module  : alu
// Design  : 8-bit Arithmetic Logic Unit
// Group   : B (PS/2)
// Week    : 1 — DV Ramp Up | Asmicore Semiconductor
// =============================================================================
// Opcodes:
//   3'b000 → ADD
//   3'b001 → SUB
//   3'b010 → AND
//   3'b011 → OR
//   3'b100 → XOR
//   3'b101 → NOT  (only uses operand a)
//   3'b110 → DIV  (returns 0xFF on divide-by-zero)
// =============================================================================

module alu (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    input  logic [2:0]  opcode,
    output logic [7:0]  result,
    output logic        zero_flag,
    output logic        overflow_flag   // TODO: implement properly (Issue-002)
);

    always_comb begin
        overflow_flag = 1'b0;   // placeholder — see issue_log.txt ISSUE-002

        case (opcode)
            3'b000: result = a + b;                          // ADD
            3'b001: result = a - b;                          // SUB
            3'b010: result = a & b;                          // AND
            3'b011: result = a | b;                          // OR
            3'b100: result = a ^ b;                          // XOR
            3'b101: result = ~a;                             // NOT
            3'b110: result = (b == 8'h00) ? 8'hFF : a / b;  // DIV (0xFF = error)
            default: result = 8'h00;
        endcase

        zero_flag = (result == 8'h00);
    end

endmodule
