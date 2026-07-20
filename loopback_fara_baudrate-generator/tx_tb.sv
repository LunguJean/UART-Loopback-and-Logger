`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2026 08:19:50 PM
// Design Name: 
// Module Name: tx_tb
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


module tx_tb(
    );
    
    parameter DBIT = 8; 
    parameter CLK_FREQ = 1_000_000;
    parameter BAUD_RATE = 100_000;
    
    
    localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    logic clk;
    logic rst;
    logic tx_start;
    logic [DBIT-1:0] tx_din;
    
    
    logic tx_done;
    logic tx; 
    
    integer i;
    uart_tx #(
        .DBIT(DBIT),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
        
    ) uarttx (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_done(tx_done),
        .tx_din(rx_din),
        .tx(tx)
    );
    
    initial begin
        clk = 0; 
        forever #5 clk = ~clk;
        
    end
    
    initial begin
        rst = 1;
        tx_start = 0;
        tx_din = 8'b00000000;
        
        #100
        rst = 0;
        tx_din = 8'b10101101;
        @(negedge clk);
        tx_start = 1;
        
        @(negedge clk);
        tx_start = 0;
                    
        @(posedge tx_done);
       
      
            
            
        #200
        $finish;
      end
    
    
    
    
    
    
endmodule
