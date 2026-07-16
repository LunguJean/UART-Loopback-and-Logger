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


module uart_rx
       #(parameter DBIT = 8,
         parameter SB_TICK = 16 
    )(
        input logic clk,rst,
        input logic rx, s_tick,
        output logic rx_done_tick,
        output logic [DBIT - 1:0] rx_dout
    );
    
    
    localparam idle = 0, start = 1, data = 2, stop = 3;
    
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [$clog2(DBIT) - 1:0] n_reg, n_next;
    reg [DBIT - 1:0] b_reg, b_next;
    
    always @(posedge clk, negedge rst)
    begin
        if(rst)
        begin
            state_reg <= idle;
            s_reg <= 4'd0;
            n_reg <= 0;
            b_reg <= 0;
        end
        else
        begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end
    
    always @(*)
    begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        rx_done_tick = 1'b0;
        case(state_reg)
       
            idle:
            begin
                if(!rx)
                begin
                    s_next = 4'd0;
                    state_next = start;
                end
            end
            start:
            begin
                if(s_tick)
                    if(s_reg == 4'd7)
                    begin
                        s_next = 4'd0;
                        n_next = 0;
                        state_next = data;
                        
                    end
                    else
                        s_next = s_reg + 1'b1;
            end
            data:
            
                 if(s_tick)
                    if(s_reg == 4'd15)
                    begin
                        s_next = 4'd0;
                        b_next = {rx,b_reg[DBIT - 1:1]};
                        if(n_reg == (DBIT - 1))
                            state_next = stop;
                        else 
                            n_next = n_reg + 1'b1;
                    end
                    else
                        s_next = s_reg + 1'b1;
             stop:
                  if(s_tick)
                     if(s_reg == (SB_TICK - 1))
                     begin
                        s_next = 4'd0;
                        rx_done_tick = 1'b1;
                        state_next = idle;
                     end   
                     else
                        s_next = s_reg + 1'b1;
                        
              default:
                    state_next = idle;
                         
           endcase
     end   
     
     assign rx_dout = b_reg;  
endmodule
