module uart_tx_tb;

    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;

    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)

    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        reset    = 1;
        tx_start = 0;
        tx_data  = 8'h00;

        // Apply Reset

        #20;
        reset = 0;

        // Transmit First Byte : 8'hA5

        @(posedge clk);
        tx_data  = 8'hA5;
        tx_start = 1;

        @(posedge clk);
        tx_start = 0;

        wait(tx_busy == 0);

        #50;
        // Transmit Second Byte : 8'h3C
        @(posedge clk);
        tx_data  = 8'h3C;
        tx_start = 1;

        @(posedge clk);
        tx_start = 0;

        wait(tx_busy == 0);

        #50;
        $finish;

    end

endmodule