`timescale 1ns / 1ps

module uart_rx_tb;

reg clk;
reg reset;
reg rx;
wire [7:0] rx_data;
wire rx_done;
wire frame_error;

uart_rx uut (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .frame_error(frame_error)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    // RESET

    reset = 1;
    rx = 1;

    #20;

    reset = 0;

    #20;


    // TEST 1 : 8'hA5
    // A5 = 1010_0101
    // LSB first:
    // Start D0 D1 D2 D3 D4 D5 D6 D7 Stop
    //   0   1  0  1  0  0  1  0  1   1

    rx = 0; #100;     // START

    rx = 1; #100;     // D0
    rx = 0; #100;     // D1
    rx = 1; #100;     // D2
    rx = 0; #100;     // D3
    rx = 0; #100;     // D4
    rx = 1; #100;     // D5
    rx = 0; #100;     // D6
    rx = 1; #100;     // D7

    rx = 1; #100;     // STOP


    #100;

    // TEST 2 : 8'h3C
    // 3C = 0011_1100
    

    rx = 0; #100;     // START

    rx = 0; #100;     // D0
    rx = 0; #100;     // D1
    rx = 1; #100;     // D2
    rx = 1; #100;     // D3
    rx = 1; #100;     // D4
    rx = 1; #100;     // D5
    rx = 0; #100;     // D6
    rx = 0; #100;     // D7

    rx = 1; #100;     // STOP


    #100;

    // TEST 3 : 8'h00
   
    rx = 0; #100;     // START

    rx = 0; #100;     // D0
    rx = 0; #100;     // D1
    rx = 0; #100;     // D2
    rx = 0; #100;     // D3
    rx = 0; #100;     // D4
    rx = 0; #100;     // D5
    rx = 0; #100;     // D6
    rx = 0; #100;     // D7

    rx = 1; #100;     // STOP


    #100;

    // TEST 4 : 8'hFF

    rx = 0; #100;     // START

    rx = 1; #100;     // D0
    rx = 1; #100;     // D1
    rx = 1; #100;     // D2
    rx = 1; #100;     // D3
    rx = 1; #100;     // D4
    rx = 1; #100;     // D5
    rx = 1; #100;     // D6
    rx = 1; #100;     // D7

    rx = 1; #100;     // STOP


    #100;

    // TEST 5 : 8'h55
    // 55 = 0101_0101
    
    // 1 0 1 0 1 0 1 0
    //
    //==================================================

    rx = 0; #100;     // START

    rx = 1; #100;     // D0
    rx = 0; #100;     // D1
    rx = 1; #100;     // D2
    rx = 0; #100;     // D3
    rx = 1; #100;     // D4
    rx = 0; #100;     // D5
    rx = 1; #100;     // D6
    rx = 0; #100;     // D7

    rx = 1; #100;     // STOP


    #100;

    // TEST 6 : 8'hAA
    // AA = 1010_1010
    rx = 0; #100;     // START

    rx = 0; #100;     // D0
    rx = 1; #100;     // D1
    rx = 0; #100;     // D2
    rx = 1; #100;     // D3
    rx = 0; #100;     // D4
    rx = 1; #100;     // D5
    rx = 0; #100;     // D6
    rx = 1; #100;     // D7

    rx = 1; #100;     // STOP


    #100;

    // TEST 7 : NOISE TEST
    // Send 8'hA5 again.
    // D0 should be 1.
  
    rx = 0; #100;     // START

    // D0 = 1
    rx = 1;
    #20;

    // Noise spike
    rx = 0;
    #10;

    rx = 1;
    #70;

    rx = 0; #100;     // D1
    rx = 1; #100;     // D2
    rx = 0; #100;     // D3
    rx = 0; #100;     // D4
    rx = 1; #100;     // D5
    rx = 0; #100;     // D6
    rx = 1; #100;     // D7
    rx = 1; #100;     // STOP
    #100;
    // TEST 8 : FRAME ERROR
    // Send 8'hA5 but make STOP BIT = 0.
    // frame_error = 1

    rx = 0; #100;     // START

    rx = 1; #100;     // D0
    rx = 0; #100;     // D1
    rx = 1; #100;     // D2
    rx = 0; #100;     // D3
    rx = 0; #100;     // D4
    rx = 1; #100;     // D5
    rx = 0; #100;     // D6
    rx = 1; #100;     // D7

    // WRONG STOP BIT
    rx = 0;
    #100;

    // Return to UART idle
    rx = 1;

    #500;

    $finish;

end

endmodule