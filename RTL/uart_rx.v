`timescale 1ns / 1ps

module uart_rx(

    input              clk,
    input              reset,
    input              rx,

    output reg [7:0]   rx_data,
    output reg         rx_done,
    output reg         frame_error

);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [1:0] next_state;

reg [7:0] shift_reg;

reg [2:0] bit_count;

reg [2:0] sample_count;

reg [2:0] ones_count;

wire sample_tick;
wire sample_enable;

assign sample_enable = (state != IDLE);

sample_generator #(
    .CLKS_PER_BIT(10),
    .OVERSAMPLE(5)
) sample_gen (
    .clk(clk),
    .reset(reset),
    .sample_enable(sample_enable),
    .sample_tick(sample_tick)
);

wire majority_bit;

assign majority_bit = ((ones_count + rx) >= 3);

always @(posedge clk) begin

    if (reset) begin

        state        <= IDLE;
        shift_reg    <= 8'd0;
        bit_count    <= 3'd0;
        sample_count <= 3'd0;
        ones_count   <= 3'd0;

        rx_data      <= 8'd0;
        rx_done      <= 1'b0;
        frame_error  <= 1'b0;

    end

    else begin

        state <= next_state;

        rx_done <= 1'b0;

        case (state)

            IDLE: begin

                sample_count <= 3'd0;
                ones_count   <= 3'd0;
                bit_count    <= 3'd0;

            end


            START: begin

                if (sample_tick) begin

                    // Fifth sample
                    if (sample_count == 3'd4) begin

                        if (majority_bit == 1'b0) begin
                            // Valid start bit
                            sample_count <= 3'd0;
                            ones_count   <= 3'd0;
                            bit_count    <= 3'd0;

                        end

                    end

                    else begin

                        sample_count <= sample_count + 1'b1;

                        if (rx == 1'b1)
                            ones_count <= ones_count + 1'b1;

                    end

                end

            end


            DATA: begin

                if (sample_tick) begin
                    // Fifth sample
                    if (sample_count == 3'd4) begin
                        // Shift the majority-voted bit into RX register
                        shift_reg <= {majority_bit, shift_reg[7:1]};

                        sample_count <= 3'd0;
                        ones_count   <= 3'd0;

                        if (bit_count == 3'd7)
                            bit_count <= 3'd0;
                        else
                            bit_count <= bit_count + 1'b1;

                    end

                    else begin

                        sample_count <= sample_count + 1'b1;

                        if (rx == 1'b1)
                            ones_count <= ones_count + 1'b1;

                    end

                end

            end
            
            STOP: begin

                if (sample_tick) begin
                    // Fifth sample
                    if (sample_count == 3'd4) begin

                        if (majority_bit == 1'b1) begin

                            // Valid stop bit
                            rx_data <= shift_reg;
                            rx_done <= 1'b1;
                            frame_error <= 1'b0;

                        end

                        else begin
                            // Stop bit should be HIGH
                            frame_error <= 1'b1;

                        end

                    end

                    else begin

                        sample_count <= sample_count + 1'b1;

                        if (rx == 1'b1)
                            ones_count <= ones_count + 1'b1;

                    end

                end

            end

        endcase

    end

end

// --------------------------------------------------
// Next-state logic
// --------------------------------------------------

always @(*) begin

    next_state = state;

    case (state)

        IDLE: begin

            if (rx == 1'b0)
                next_state = START;

        end


        START: begin

            if (sample_tick && sample_count == 3'd4) begin

                if (majority_bit == 1'b0)
                    next_state = DATA;
                else
                    next_state = IDLE;

            end

        end


        DATA: begin

            if (sample_tick && sample_count == 3'd4) begin

                if (bit_count == 3'd7)
                    next_state = STOP;

            end

        end


        STOP: begin

            if (sample_tick && sample_count == 3'd4)
                next_state = IDLE;

        end


        default:
            next_state = IDLE;

    endcase

end

endmodule
