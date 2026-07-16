`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2026 04:24:35 PM
// Design Name: 
// Module Name: top_loopback
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_loopback#(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 9600

) (    
    input logic clk, 
    input logic rst,
    input logic rx,
    output logic tx
    );
    
    
    wire s_tick;
    wire [7:0] rx_data;
    wire rx_done_tick;
    wire tx_done_tick;
    
    
    baud_rate #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baudrate (
        .clk(clk),
        .rst(rst),
        .baud_tick(s_tick)
    );
    
    uart_rx uartrx(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .s_tick(s_tick),
        .rx_done_tick(rx_done_tick),
        .rx_dout(rx_data)
    );
    
    uart_tx uarttx (
        .clk(clk),
        .rst(rst),
        .tx_start(rx_done_tick),
        .s_tick(s_tick),
        .tx_din(rx_data),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );
endmodule
