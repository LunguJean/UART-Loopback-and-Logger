`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2026 08:19:50 PM
// Design Name: 
// Module Name: rx_tb
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


module rx_tb(
    );
    
    parameter DBIT = 8; 
    parameter CLK_FREQ = 1_000_000;
    parameter BAUD_RATE = 100_000;
    
    
    localparam CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    logic clk;
    logic rst;
    logic rx;
    
    
    logic rx_done;
    logic [DBIT - 1:0] rx_dout;
    integer i;
    uart_rx #(
        .DBIT(DBIT),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
        
    ) uartrx (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_done(rx_done),
        .rx_dout(rx_dout)
    );
    
    initial begin
        clk = 0; 
        forever #5 clk = ~clk;
        
    end
    
    initial begin
        rst = 1;
        rx = 1;
        #100
        rst = 0;
        
        @(negedge clk);

        rx = 0;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
            
            
            
            
        rx = 1;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
        rx = 0;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
        rx = 1;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
        rx = 1;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
        rx = 0;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
        rx = 1;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
        rx = 0;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
        rx = 1;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
            
        
        rx = 1;
        for(i=0;i<CLK_PER_BIT;i=i+1)
            @(negedge clk);
            
        #1000
        $finish;
      end
    
    
    
    
    
    
endmodule
