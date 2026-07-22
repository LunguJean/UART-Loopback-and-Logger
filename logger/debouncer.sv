`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2026 11:53:44 PM
// Design Name: 
// Module Name: debouncer_and_sync
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


module debouncer(
    input logic clk,
    
    input logic push,
    input logic timer_done,
    output logic timer_reset,
    output logic debounced
    );
    logic [1:0] state_next,state;
    logic [1:0] s0=2'b00;
    logic [1:0] s1=2'b01;
    logic [1:0] s2=2'b10;
    logic [1:0] s3=2'b11;
    
    always_ff @(posedge clk)
    begin
        
            state <= state_next;    
    end
    
    always_comb
    begin
        state_next = state;
        case(state)
            s0: if(!push)
                    state_next = s0;
                else if(push)
                        state_next = s1;
            s1: if(!push)
                    state_next = s0;
                else if(push && !timer_done)
                    state_next = s1;
                else if(push && timer_done)
                    state_next = s2;
            s2: if(push)
                    state_next = s2;
                else if(!push)
                    state_next = s3;
            s3: if(push)
                    state_next = s2;
                else if(!push && !timer_done)
                    state_next = s3;
                else if(!push && timer_done)
                    state_next =s0;
            default: state_next = s0;   
        endcase
    end
    
    assign timer_reset = (state == s0) || (state == s2);
    assign debounced = (state == s2) || (state == s3);
    
endmodule
