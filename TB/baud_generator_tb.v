`timescale 1ns / 1ps

module baud_generator_tb;

    reg clk;
    reg reset;
    reg enable;

    wire baud_tick;

    // Instantiate DUT
    baud_generator #(
        .CLKS_PER_BIT(10)
    ) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .baud_tick(baud_tick)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Initialize
        reset  = 1;
        enable = 0;

        #20;
        reset = 0;

        // Test 1 : Enable baud generator
        #10;
        enable = 1;
        #250;

        // Test 2 : Disable baud generator
        enable = 0;

        #100;
        // Test 3 : Enable again
        enable = 1;

        // Counter should restart from 0
        #250;

        $finish;

    end

endmodule

