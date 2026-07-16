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
    parameter SB_TICK = 16;
    
    logic clk;
    logic rst;
    logic rx;
    logic s_tick;
    
    logic rx_done_tick;
    logic [DBIT - 1:0] rx_dout;
    integer i;
    uart_rx #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK)
    ) uartrx (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .s_tick(s_tick),
        .rx_done_tick(rx_done_tick),
        .rx_dout(rx_dout)
    );
    
    initial begin
        clk = 0; 
        forever #5 clk = ~clk;
        
    end
    
    initial begin
        s_tick = 0;
        
        forever begin
            #35;
            s_tick = 1;
            #10;
            s_tick = 0;
        end
    
    end
    
    initial begin
        rst = 1;
        rx = 1;
        #100
        rst = 0;
        rx = 0;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
            
            
            
            
        rx = 1;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
        rx = 0;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
        rx = 1;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
        rx = 1;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
        rx = 0;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
        rx = 1;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
        rx = 0;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
        rx = 1;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
            
        
        rx = 1;
        for(i=0;i<16;i=i+1)
            @(posedge s_tick)
            
        #100
        $finish;
      end
    
    
    
    
    
    
endmodule
