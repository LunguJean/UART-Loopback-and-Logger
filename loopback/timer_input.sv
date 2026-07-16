`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 04:48:10 PM
// Design Name: 
// Module Name: timer_input
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


module timer_input
    #(parameter BITS = 4)(
        input logic clk,
        input logic rst,
        input wire enable,
        input wire [BITS - 1:0] FINAL_VALUE,
        output wire done
    );
    
    logic [BITS - 1:0] Q_reg, Q_next;
    
    always @(posedge clk, negedge rst)
    begin
        if(!rst)
            Q_reg <= {BITS{1'b0}};
        else if(enable)
                Q_reg <= Q_next;
              else 
                    Q_reg <= Q_reg;
    
    end
    assign done = Q_reg == FINAL_VALUE;
    
    always @(*)
        Q_next = done ? {BITS{1'b0}} : Q_reg+1'b1;
    
    
    
endmodule
