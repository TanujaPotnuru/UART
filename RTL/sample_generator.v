`timescale 1ns / 1ps

module sample_generator #(
    parameter CLKS_PER_BIT = 10,
    parameter OVERSAMPLE   = 5
)(
    input  clk,
    input reset,
    input sample_enable,

    output reg sample_tick
);

localparam SAMPLE_PERIOD = CLKS_PER_BIT / OVERSAMPLE;

reg [1:0] count;

always @(posedge clk) begin

    if (reset) begin
        count       <= 2'd0;
        sample_tick <= 1'b0;
    end

    else if (!sample_enable) begin
        count       <= 2'd0;
        sample_tick <= 1'b0;
    end

    else begin

        if (count == SAMPLE_PERIOD-1) begin
            count       <= 2'd0;
            sample_tick <= 1'b1;
        end

        else begin
            count       <= count + 1'b1;
            sample_tick <= 1'b0;
        end

    end

end

endmodule
