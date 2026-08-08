`timescale 1ns / 1ps

module baud_generator #(

    parameter CLKS_PER_BIT = 10

)(
    input  clk,
    input  reset,
    input  enable,

    output reg baud_tick
);

reg [3:0] counter;

always @(posedge clk) begin

    if (reset) begin
        counter   <= 4'd0;
        baud_tick <= 1'b0;
    end

    else if (enable) begin

        if (counter == CLKS_PER_BIT - 1) begin
            counter   <= 4'd0;
            baud_tick <= 1'b1;
        end
        else begin
            counter   <= counter + 1'b1;
            baud_tick <= 1'b0;
        end

    end

    else begin
        counter   <= 4'd0;
        baud_tick <= 1'b0;
    end

end

endmodule