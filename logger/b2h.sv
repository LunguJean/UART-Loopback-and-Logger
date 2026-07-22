`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 07:55:24 PM
// Design Name: 
// Module Name: b2h
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


module b2h(
    input  logic [15:0] binary,

    output logic [3:0] hex3,
    output logic [3:0] hex2,
    output logic [3:0] hex1,
    output logic [3:0] hex0
);

    assign hex3 = binary[15:12];
    assign hex2 = binary[11:8];
    assign hex1 = binary[7:4];
    assign hex0 = binary[3:0];

endmodule
