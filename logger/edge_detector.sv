`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2026 12:01:46 AM
// Design Name: 
// Module Name: edge_detector
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


module edge_detector(
    input logic clk,
    input logic level,
    output logic p_level
    );
    
    logic prev_level;
    
    
    always_ff @(posedge clk)
    begin   
         prev_level <= level;
    end
    
    assign p_level = level && !prev_level;
    
    
endmodule
