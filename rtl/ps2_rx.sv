// =============================================================================
// Module  : ps2_rx
// Design  : Basic PS/2 Serial Receiver
// Group   : B (PS/2)
// Week    : 1 — DV Ramp Up | Asmicore Semiconductor
// =============================================================================
// Frame format (11 bits, LSB first):
//   [START=0] [D0][D1][D2][D3][D4][D5][D6][D7] [PARITY] [STOP=1]
//
// Notes:
//   - Data sampled on falling edge of ps2_clk
//   - Parity check NOT implemented (see issue_log.txt ISSUE-003)
//   - Clock glitch / debounce NOT implemented (ISSUE-004)
// =============================================================================

module ps2_rx (
    input  logic        clk,        // System clock
    input  logic        rst,        // Synchronous active-high reset
    input  logic        ps2_clk,    // PS/2 clock from device
    input  logic        ps2_data,   // PS/2 serial data
    output logic [7:0]  rx_data,    // Received byte (valid when rx_valid=1)
    output logic        rx_valid    // Pulses high for one cycle when byte ready
);

    // -------------------------------------------------------------------------
    // Falling-edge detection on ps2_clk
    // -------------------------------------------------------------------------
    logic ps2_clk_prev;
    logic falling_edge;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) ps2_clk_prev <= 1'b1;
        else     ps2_clk_prev <= ps2_clk;
    end

    assign falling_edge = ps2_clk_prev & ~ps2_clk;

    // -------------------------------------------------------------------------
    // FSM state encoding
    // -------------------------------------------------------------------------
    typedef enum logic [2:0] {
        IDLE   = 3'd0,
        START  = 3'd1,
        DATA   = 3'd2,
        PARITY = 3'd3,
        STOP   = 3'd4
    } state_t;

    state_t      state;
    logic [7:0]  shift_reg;
    logic [2:0]  bit_count;

    // -------------------------------------------------------------------------
    // FSM — sequential
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            rx_valid  <= 1'b0;
            rx_data   <= 8'h00;
            shift_reg <= 8'h00;
            bit_count <= 3'd0;
        end else begin
            rx_valid <= 1'b0;   // default: de-assert every cycle

            case (state)

                IDLE: begin
                    // Start bit = ps2_data LOW on a falling clock edge
                    if (falling_edge && ps2_data == 1'b0)
                        state <= DATA;
                end

                DATA: begin
                    if (falling_edge) begin
                        // Shift in LSB first
                        shift_reg <= {ps2_data, shift_reg[7:1]};

                        if (bit_count == 3'd7) begin
                            state     <= PARITY;
                            bit_count <= 3'd0;
                        end else begin
                            bit_count <= bit_count + 3'd1;
                        end
                    end
                end

                PARITY: begin
                    // TODO: verify odd parity (ISSUE-003)
                    if (falling_edge)
                        state <= STOP;
                end

                STOP: begin
                    if (falling_edge) begin
                        rx_data  <= shift_reg;
                        rx_valid <= 1'b1;
                        state    <= IDLE;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
