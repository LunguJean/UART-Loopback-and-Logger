`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2026 01:09:39 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_tx
       #(parameter DBIT = 8,
         parameter int CLK_FREQ = 100_000_000,
         parameter int BAUD_RATE = 9600
    )(
        input logic clk,rst,
        input logic tx_start,
        input logic [DBIT - 1:0] tx_din,
        output logic tx_done,
        output logic tx
    );
    
    
    localparam idle = 0, start = 1, data = 2, stop = 3;
    
    localparam integer CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer COUNT_BITS = $clog2(CLK_PER_BIT);
    
    logic [COUNT_BITS - 1:0] clock_count_reg;
    logic [COUNT_BITS - 1:0] clock_count_next;
    
    logic [1:0] state_reg;
    logic [1:0] state_next;
    logic [$clog2(DBIT) - 1:0] n_reg, n_next;
    logic [DBIT - 1:0] b_reg, b_next;
    logic tx_reg,tx_next; 
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state_reg <= idle;
            clock_count_reg <= '0;
            n_reg <= '0;
            b_reg <= '0;
            tx_reg <= 1'b1;
        end
        else
        begin
            state_reg <= state_next;
            clock_count_reg <= clock_count_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end
    
    always @(*)
    begin
        state_next = state_reg;
        clock_count_next = clock_count_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;
        tx_done = 1'b0;
        
        case(state_reg)
       
            idle:
            begin
                tx_next = 1'b1;
                clock_count_next = '0;
                n_next = '0;
                
                if(tx_start == 1'b1)
                begin
                   
                    b_next = tx_din;
                    state_next = start;
                end
            end
            start:
            begin
                tx_next = 1'b0;
                    if(clock_count_reg == CLK_PER_BIT-1)
                    begin
                        clock_count_next = '0;
                       
                        state_next = data;
                        
                    end
                    else
                       clock_count_next = clock_count_reg + 1'b1;
            end
            data:
            begin
                 tx_next = b_reg[0];
                    if(clock_count_reg == CLK_PER_BIT-1)
                    begin
                        clock_count_next = '0;
                        b_next = b_reg >> 1;
                        if(n_reg == DBIT - 1)
                        begin    
                            n_next = '0;
                            state_next = stop;
                        end
                        else 
                            n_next = n_reg + 1'b1;
                    end
                    else
                        clock_count_next = clock_count_reg + 1'b1;
             end
             stop:
             begin
                  tx_next = 1'b1;
                  
                     if(clock_count_reg == CLK_PER_BIT-1)
                     begin
                        clock_count_next = 0;
                        
                        tx_done = 1'b1;
                        state_next = idle;
                     end   
                     else
                       clock_count_next = clock_count_reg + 1'b1;
              end          
              default:
              begin
                    state_next = idle;
                    clock_count_next = 0;
                    n_next = 0;
                    b_next = 0;
                    tx_next = 1'b1;
              end           
           endcase
     end   
     
     assign tx = tx_reg;  
endmodule
