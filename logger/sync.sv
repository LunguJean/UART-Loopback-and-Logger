`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2026 11:38:33 PM
// Design Name: 
// Module Name: sync
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


module sync(
    input logic in,
    input logic clk,
    output logic out
    );
    
    logic data;
    
    always_ff @(posedge clk)
    begin
        data <= in;
        out <= data;
        //2 flip-flop-uri pentru evitarea metastabilitatii
    end
    
endmodule
