`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 04:06:35 PM
// Design Name: 
// Module Name: command
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


module command(
    input logic clk,
    input logic rst,
    
    input logic [7:0] fifo_data,
    input logic fifo_empty,
    output logic fifo_read_en,
    
    input logic controller_ready,
    
    output logic cmd_inc,
    output logic cmd_dec,
    output logic cmd_res,
    output logic cmd_status,
    output logic cmd_help,
    output logic cmd_invalid
    
    
    );
    
    localparam logic [1:0] idle = 2'b00;
    localparam logic [1:0] read = 2'b01;
    localparam logic [1:0] save = 2'b10;
    localparam logic [1:0] decode = 2'b11;
    
    logic [1:0] state, state_next;
    
    logic [7:0] caracter;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= idle;
            caracter     <= 8'h00;
            
        end
        else begin
            state <= state_next;
            if(state == save)
                caracter <= fifo_data;
        end     
    end
    
    
    always @(*)
    begin
        state_next = state;
        
        fifo_read_en = 1'b0;
        
        cmd_inc = 0;
        cmd_dec = 0;
        cmd_res = 0;
        cmd_status = 0;
        cmd_help = 0;
        cmd_invalid = 0;
        
        case(state)
            idle:
            begin
                if(!fifo_empty && controller_ready)
                    state_next = read;
            end
            
            read:
            begin
                fifo_read_en = 1'b1;
                state_next = save;
            end
            
            save:
            begin
                state_next = decode;
            end
            
            decode:
            begin
                   if((caracter == "I") || (caracter == "i"))
                        cmd_inc = 1'b1;
                   

                   if((caracter == "D") || (caracter == "d"))
                        cmd_dec = 1'b1;
                   

                   if((caracter == "R") || (caracter == "r"))
                        cmd_res = 1'b1;
                   

                   if((caracter == "S") || (caracter == "s"))
                        cmd_status = 1'b1;
                   

                   if(caracter == "?")
                        cmd_help = 1'b1;
                   

                   else
                        cmd_invalid = 1'b1;
                   
                 state_next = idle;
            end
        endcase
    end
    
endmodule
