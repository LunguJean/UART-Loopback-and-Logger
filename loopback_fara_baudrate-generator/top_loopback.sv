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
    parameter DBIT = 8,
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 9600

) (    
    input logic clk, 
    input logic rst,
    input logic rx,
    output logic tx
    );
    
    
    
    logic [7:0] rx_data;
    logic rx_done;
    logic tx_done;
    
    
   
    
    uart_rx #(
        .DBIT(DBIT),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
        ) uartrx(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_done(rx_done),
        .rx_dout(rx_data)
    );
    
//    uart_tx #(
//            .DBIT(DBIT),
//            .CLK_FREQ(CLK_FREQ),
//            .BAUD_RATE(BAUD_RATE)
//         ) uarttx (
//        .clk(clk),
//        .rst(rst),
//        .tx_start(rx_done),
//        .tx_din(rx_data),
//        .tx_done(tx_done),
//        .tx(tx)
//    );
endmodule
