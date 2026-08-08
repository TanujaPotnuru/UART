`timescale 1ns / 1ps

module sample_generator_tb;

    reg clk;
    reg reset;
    reg sample_enable;

    wire sample_tick;

    sample_generator uut (
        .clk(clk),
        .reset(reset),
        .sample_enable(sample_enable),
        .sample_tick(sample_tick)
    );

    // 100 MHz clock
    // Period = 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Initial values
        reset         = 1;
        sample_enable = 0;

        #20;
        reset = 0;

        // Test 1: Generator disabled
        // Counter should remain 0
        // sample_tick should remain 0

        #30;

        // Test 2: Enable sampling
        sample_enable = 1;

        // SAMPLE_PERIOD = 10/5 = 2

        #100;

        // Test 3: Disable generator
        sample_enable = 0;

        #30;

        // Test 4: Enable again
        sample_enable = 1;

        #60;

        $finish;

    end

endmodule
