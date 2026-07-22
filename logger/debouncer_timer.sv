`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2026 05:38:54 PM
// Design Name: 
// Module Name: debouncer_timer
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


module debouncer_timer #(
    parameter int FINAL_VALUE = 1_000_000   // 10 ms la 100 MHz
)(
    input  logic clk,
    input  logic timer_reset,
    output logic timer_done
);

localparam int BITS = $clog2(FINAL_VALUE);

logic [BITS-1:0] count;

always_ff @(posedge clk) begin
    
    if(timer_reset)
        count <= 'b0;
    else if(count < FINAL_VALUE - 1)
        count <= count + 1'b1;
    else
        count <= count;
end

assign timer_done = (count == FINAL_VALUE - 1);

endmodule
