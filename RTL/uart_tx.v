`timescale 1ns/1ps

module uart_tx(

    input              clk,
    input              reset,

    input              tx_start,
    input      [7:0]   tx_data,

    output reg         tx,
    output reg         tx_busy

);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state, next_state;
reg [7:0] shift_reg;
reg [2:0] bit_count;

wire baud_tick;
wire baud_enable;

// Baud Generator Enable

assign baud_enable = (state != IDLE) || tx_start;

// Baud Generator Instance

baud_generator #(
    .CLKS_PER_BIT(10)
) baud_gen (

    .clk(clk),
    .reset(reset),
    .enable(baud_enable),
    .baud_tick(baud_tick)

);

always @(posedge clk) begin

    if(reset) begin
        state     <= IDLE;
        shift_reg <= 8'd0;
        bit_count <= 3'd0;
    end

    else begin

        state <= next_state;

        case(state)

            IDLE:
            begin
                if(tx_start) begin
                    shift_reg <= tx_data;
                    bit_count <= 3'd0;
                end
            end

            DATA:
            begin
                if(baud_tick) begin
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count + 1'b1;
                end
            end

        endcase

    end

end

// Combinational Block

always @(*) begin

    next_state = state;
    tx_busy    = !(state == IDLE);

    case(state)

        IDLE:
        begin
            tx = 1'b1;

            if(tx_start) begin
                next_state = START;
                tx_busy    = 1'b1;
            end
        end

        START:
        begin
            tx = 1'b0;

            if(baud_tick)
                next_state = DATA;
        end

        DATA:
        begin
            tx = shift_reg[0];

            if(baud_tick) begin
                if(bit_count == 3'd7)
                    next_state = STOP;
            end
        end

        STOP:
        begin
            tx = 1'b1;

            if(baud_tick)
                next_state = IDLE;
        end

    endcase

end

endmodule
