`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 12:03:54 AM
// Design Name: 
// Module Name: FSM_contor
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


module FSM_contor(
    input logic clk,
    input logic rst, 
    
    input logic value_inc,
    input logic value_dec,
    input logic value_reset,
    
    output logic [15:0] count,
    output logic [15:0] led
    );
    
    logic [1:0] state, state_next;
    logic [15:0] count_next;
    
    logic [1:0] IDLE = 2'b00;
    logic [1:0] INC = 2'b01;
    logic [1:0] DEC = 2'b10;
    logic [1:0] RESET = 2'b11;
    
    always_ff @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state <= IDLE;
            count <= 16'd0;
        end
        else 
        begin
            state <= state_next;
            count <= count_next;
        end
    end
    
    always @(*)
    begin
        state_next = state;
        count_next = count;
        
        case(state)
        
            IDLE:
            begin
                if(value_reset)
                    state_next = RESET;  
                else if(value_inc)
                        state_next = INC;
                     else if(value_dec)
                            state_next = DEC;
                                  
            end
            
            INC: 
            begin
                count_next = count + 16'd1;
                state_next = IDLE;
            end
            
            DEC:
            begin
                count_next = count - 16'd1;
                state_next = IDLE;
            end
                
            RESET:  
            begin
                count_next = 16'd0;
                state_next = IDLE;
            end
            
            default: begin
                    state_next = IDLE;
                    count_next = 16'd0;
                end
            endcase
    end
    
    assign led = count;
    
    
endmodule



