`timescale 1ns / 1ps

module uart_top(

    input              clk,
    input              reset,

    // TX interface
    input              tx_start,
    input      [7:0]   tx_data,
    output             tx,
    output             tx_busy,

    // RX interface
    input              rx,
    output     [7:0]   rx_data,
    output             rx_done,
    output             frame_error

);


// UART TRANSMITTER

uart_tx transmitter (

    .clk       (clk),
    .reset     (reset),

    .tx_start  (tx_start),
    .tx_data   (tx_data),

    .tx        (tx),
    .tx_busy   (tx_busy)

);


// UART RECEIVER

uart_rx receiver (

    .clk         (clk),
    .reset       (reset),
    .rx          (rx),

    .rx_data     (rx_data),
    .rx_done     (rx_done),
    .frame_error (frame_error)

);

endmodule
