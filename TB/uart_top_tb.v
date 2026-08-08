`timescale 1ns / 1ps

module uart_top_tb;

    reg        clk;
    reg        reset;
    reg        tx_start;
    reg [7:0]  tx_data;

    wire       tx;
    wire       tx_busy;
    wire [7:0] rx_data;
    wire       rx_done;
    wire       frame_error;

    // TX connected directly to RX
    wire rx;

    assign rx = tx;

    uart_top uut (
        .clk         (clk),
        .reset       (reset),

        .tx_start    (tx_start),
        .tx_data     (tx_data),

        .tx          (tx),
        .tx_busy     (tx_busy),

        .rx          (rx),
        .rx_data     (rx_data),
        .rx_done     (rx_done),
        .frame_error (frame_error)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Initialize
        reset    = 1;
        tx_start = 0;
        tx_data  = 8'h00;

        // Reset
        #20;
        reset = 0;

        #50;

        // TEST 1 : A5

        tx_data  = 8'hA5;
        tx_start = 1;

        #10;
        tx_start = 0;

        // 10 bits × 100 ns = 1000 ns
        #1100;

        // TEST 2 : 3C

        tx_data  = 8'h3C;
        tx_start = 1;

        #10;
        tx_start = 0;

        #1100;


        // TEST 3 : FF

        tx_data  = 8'hFF;
        tx_start = 1;

        #10;
        tx_start = 0;

        #1100;

        // TEST 4 : 00

        tx_data  = 8'h00;
        tx_start = 1;

        #10;
        tx_start = 0;

        #1100;

        // TEST 5 : 55

        tx_data  = 8'h55;
        tx_start = 1;

        #10;
        tx_start = 0;

        #1100;

        // TEST 6 : AA

        tx_data  = 8'hAA;
        tx_start = 1;

        #10;
        tx_start = 0;

        #1100;

        // END SIMULATION

        #100;

        $finish;

    end

endmodule