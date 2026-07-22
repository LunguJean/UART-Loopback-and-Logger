`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 06:41:30 PM
// Design Name: 
// Module Name: message
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


module message(
    input logic clk,
    input logic rst, 
    
    input logic message_inc,
    input logic message_dec,
    input logic message_res,
    input logic message_status,
    input logic message_help,
    input logic message_invalid,
    
    input  logic [3:0] hex3,
    input  logic [3:0] hex2,
    input  logic [3:0] hex1,
    input  logic [3:0] hex0,
    
    input logic tx_fifo_full,
    output logic [7:0] tx_fifo_data,
    output logic tx_fifo_write_en,
    
    output logic message_ready
    );
    
    
    localparam logic idle = 1'b0;
    localparam logic send = 1'b1;

    logic state;
    
    localparam logic [2:0] NO_MESSAGE = 3'b000;
    localparam logic [2:0] MESSAGE_INC = 3'b001;
    localparam logic [2:0] MESSAGE_DEC = 3'b010;
    localparam logic [2:0] MESSAGE_RES = 3'b011;
    localparam logic [2:0] MESSAGE_STATUS = 3'b100;
    localparam logic [2:0] MESSAGE_HELP = 3'b101;
    localparam logic [2:0] MESSAGE_INVALID = 3'b110;
    
    logic [2:0] message_reg;
    
    logic [5:0] index; 
    
    logic [5:0] message_length;
    
    
    logic [3:0] hex3_reg;
    logic [3:0] hex2_reg;
    logic [3:0] hex1_reg;
    logic [3:0] hex0_reg;

    
    logic [7:0] ascii3;
    logic [7:0] ascii2;
    logic [7:0] ascii1;
    logic [7:0] ascii0;
    
     always_comb begin

        if (hex3_reg < 4'd10)
            ascii3 = 8'h30 + hex3_reg;
        else
            ascii3 = 8'h41 + hex3_reg - 4'd10;

        if (hex2_reg < 4'd10)
            ascii2 = 8'h30 + hex2_reg;
        else
            ascii2 = 8'h41 + hex2_reg - 4'd10;

        if (hex1_reg < 4'd10)
            ascii1 = 8'h30 + hex1_reg;
        else
            ascii1 = 8'h41 + hex1_reg - 4'd10;

        if (hex0_reg < 4'd10)
            ascii0 = 8'h30 + hex0_reg;
        else
            ascii0 = 8'h41 + hex0_reg - 4'd10;

    end

     always_ff @(posedge clk or posedge rst) 
     begin
        if (rst) 
        begin
            state <= idle;
            message_reg <= NO_MESSAGE;
            index <= 6'd0;
            message_length <= 6'd0;

            hex3_reg <= 4'd0;
            hex2_reg <= 4'd0;
            hex1_reg <= 4'd0;
            hex0_reg <= 4'd0;
        end
        else
           case(state)
                idle:
                begin
                    index <= 6'd0;

                    if (message_res) 
                    begin
                        message_reg <= MESSAGE_RES;
                        message_length <= 6'd25;

                        hex3_reg <= hex3;
                        hex2_reg <= hex2;
                        hex1_reg <= hex1;
                        hex0_reg <= hex0;

                        state <= send;
                    end
                     else if (message_inc) 
                     begin
                        message_reg <= MESSAGE_INC;
                        message_length <= 6'd23;

                        hex3_reg <= hex3;
                        hex2_reg <= hex2;
                        hex1_reg <= hex1;
                        hex0_reg <= hex0;

                        state <= send;
                     end 
                      else if (message_dec) 
                      begin
                        message_reg <= MESSAGE_DEC;
                        message_length <= 6'd23;

                        hex3_reg <= hex3;
                        hex2_reg <= hex2;
                        hex1_reg <= hex1;
                        hex0_reg <= hex0;

                        state <= send;
                      end  
                        
                      else if (message_status) 
                      begin
                      
                        message_reg <= MESSAGE_STATUS;
                        message_length <= 6'd26;

                        hex3_reg <= hex3;
                        hex2_reg <= hex2;
                        hex1_reg <= hex1;
                        hex0_reg <= hex0;

                        state <= send;
                    end

                    else if (message_help) 
                    begin
                        message_reg <= MESSAGE_HELP;
                        message_length <= 6'd35;
                        state <= send;
                    end

                    else if (message_invalid) 
                    begin
                        message_reg <= MESSAGE_INVALID;
                        message_length <= 6'd24;
                        state <= send;
                    end

                end
                
                send:
                begin
                     if (!tx_fifo_full) 
                     begin

                        if (index == message_length - 1'b1) begin
                            index <= 6'd0;
                            message_reg <= NO_MESSAGE;
                            state <= idle;
                        end
                        else begin
                            index <= index + 1'b1;
                        end
                    end

                end
                default: begin
                    state <= idle;
                    message_reg <= NO_MESSAGE;
                    index <= 6'd0;
                    message_length <= 6'd0;
                end
             endcase      
      end     
     
      always_comb begin
        tx_fifo_data     = 8'h00;
        tx_fifo_write_en = 1'b0;

        if ((state == send) && !(tx_fifo_full)) begin
            tx_fifo_write_en = 1'b1;

            case (message_reg)

                // "INC: Counter = 0xXXXX\r\n"

                MESSAGE_INC: begin
                    case (index)
                        6'd0:  tx_fifo_data = "I";
                        6'd1:  tx_fifo_data = "N";
                        6'd2:  tx_fifo_data = "C";
                        6'd3:  tx_fifo_data = ":";
                        6'd4:  tx_fifo_data = " ";
                        6'd5:  tx_fifo_data = "C";
                        6'd6:  tx_fifo_data = "o";
                        6'd7:  tx_fifo_data = "u";
                        6'd8:  tx_fifo_data = "n";
                        6'd9:  tx_fifo_data = "t";
                        6'd10: tx_fifo_data = "e";
                        6'd11: tx_fifo_data = "r";
                        6'd12: tx_fifo_data = " ";
                        6'd13: tx_fifo_data = "=";
                        6'd14: tx_fifo_data = " ";
                        6'd15: tx_fifo_data = "0";
                        6'd16: tx_fifo_data = "x";
                        6'd17: tx_fifo_data = ascii3;
                        6'd18: tx_fifo_data = ascii2;
                        6'd19: tx_fifo_data = ascii1;
                        6'd20: tx_fifo_data = ascii0;
                        6'd21: tx_fifo_data = 8'h0D;
                        6'd22: tx_fifo_data = 8'h0A; 
                        default: tx_fifo_data = 8'h00;
                    endcase
                end

                // "DEC: Counter = 0xXXXX\r\n"

                MESSAGE_DEC: begin
                    case (index)
                        6'd0:  tx_fifo_data = "D";
                        6'd1:  tx_fifo_data = "E";
                        6'd2:  tx_fifo_data = "C";
                        6'd3:  tx_fifo_data = ":";
                        6'd4:  tx_fifo_data = " ";
                        6'd5:  tx_fifo_data = "C";
                        6'd6:  tx_fifo_data = "o";
                        6'd7:  tx_fifo_data = "u";
                        6'd8:  tx_fifo_data = "n";
                        6'd9:  tx_fifo_data = "t";
                        6'd10: tx_fifo_data = "e";
                        6'd11: tx_fifo_data = "r";
                        6'd12: tx_fifo_data = " ";
                        6'd13: tx_fifo_data = "=";
                        6'd14: tx_fifo_data = " ";
                        6'd15: tx_fifo_data = "0";
                        6'd16: tx_fifo_data = "x";
                        6'd17: tx_fifo_data = ascii3;
                        6'd18: tx_fifo_data = ascii2;
                        6'd19: tx_fifo_data = ascii1;
                        6'd20: tx_fifo_data = ascii0;
                        6'd21: tx_fifo_data = 8'h0D;
                        6'd22: tx_fifo_data = 8'h0A;
                        default: tx_fifo_data = 8'h00;
                    endcase
                end

                // "RESET: Counter = 0xXXXX\r\n"

                MESSAGE_RES: begin
                    case (index)
                        6'd0:  tx_fifo_data = "R";
                        6'd1:  tx_fifo_data = "E";
                        6'd2:  tx_fifo_data = "S";
                        6'd3:  tx_fifo_data = "E";
                        6'd4:  tx_fifo_data = "T";
                        6'd5:  tx_fifo_data = ":";
                        6'd6:  tx_fifo_data = " ";
                        6'd7:  tx_fifo_data = "C";
                        6'd8:  tx_fifo_data = "o";
                        6'd9:  tx_fifo_data = "u";
                        6'd10: tx_fifo_data = "n";
                        6'd11: tx_fifo_data = "t";
                        6'd12: tx_fifo_data = "e";
                        6'd13: tx_fifo_data = "r";
                        6'd14: tx_fifo_data = " ";
                        6'd15: tx_fifo_data = "=";
                        6'd16: tx_fifo_data = " ";
                        6'd17: tx_fifo_data = "0";
                        6'd18: tx_fifo_data = "x";
                        6'd19: tx_fifo_data = ascii3;
                        6'd20: tx_fifo_data = ascii2;
                        6'd21: tx_fifo_data = ascii1;
                        6'd22: tx_fifo_data = ascii0;
                        6'd23: tx_fifo_data = 8'h0D;
                        6'd24: tx_fifo_data = 8'h0A;
                        default: tx_fifo_data = 8'h00;
                    endcase
                end

                // "STATUS: Counter = 0xXXXX\r\n"

                MESSAGE_STATUS: begin
                    case (index)
                        6'd0:  tx_fifo_data = "S";
                        6'd1:  tx_fifo_data = "T";
                        6'd2:  tx_fifo_data = "A";
                        6'd3:  tx_fifo_data = "T";
                        6'd4:  tx_fifo_data = "U";
                        6'd5:  tx_fifo_data = "S";
                        6'd6:  tx_fifo_data = ":";
                        6'd7:  tx_fifo_data = " ";
                        6'd8:  tx_fifo_data = "C";
                        6'd9:  tx_fifo_data = "o";
                        6'd10: tx_fifo_data = "u";
                        6'd11: tx_fifo_data = "n";
                        6'd12: tx_fifo_data = "t";
                        6'd13: tx_fifo_data = "e";
                        6'd14: tx_fifo_data = "r";
                        6'd15: tx_fifo_data = " ";
                        6'd16: tx_fifo_data = "=";
                        6'd17: tx_fifo_data = " ";
                        6'd18: tx_fifo_data = "0";
                        6'd19: tx_fifo_data = "x";
                        6'd20: tx_fifo_data = ascii3;
                        6'd21: tx_fifo_data = ascii2;
                        6'd22: tx_fifo_data = ascii1;
                        6'd23: tx_fifo_data = ascii0;
                        6'd24: tx_fifo_data = 8'h0D;
                        6'd25: tx_fifo_data = 8'h0A;
                        default: tx_fifo_data = 8'h00;
                    endcase
                end

                // "I=INC D=DEC R=RESET S=STATUS ?=HELP\r\n"

                MESSAGE_HELP: begin
                    case (index)
                        6'd0:  tx_fifo_data = "I";
                        6'd1:  tx_fifo_data = "=";
                        6'd2:  tx_fifo_data = "I";
                        6'd3:  tx_fifo_data = "N";
                        6'd4:  tx_fifo_data = "C";
                        6'd5:  tx_fifo_data = " ";

                        6'd6:  tx_fifo_data = "D";
                        6'd7:  tx_fifo_data = "=";
                        6'd8:  tx_fifo_data = "D";
                        6'd9:  tx_fifo_data = "E";
                        6'd10: tx_fifo_data = "C";
                        6'd11: tx_fifo_data = " ";

                        6'd12: tx_fifo_data = "R";
                        6'd13: tx_fifo_data = "=";
                        6'd14: tx_fifo_data = "R";
                        6'd15: tx_fifo_data = "E";
                        6'd16: tx_fifo_data = "S";
                        6'd17: tx_fifo_data = "E";
                        6'd18: tx_fifo_data = "T";
                        6'd19: tx_fifo_data = " ";

                        6'd20: tx_fifo_data = "S";
                        6'd21: tx_fifo_data = "=";
                        6'd22: tx_fifo_data = "S";
                        6'd23: tx_fifo_data = "T";
                        6'd24: tx_fifo_data = "A";
                        6'd25: tx_fifo_data = "T";
                        6'd26: tx_fifo_data = "U";
                        6'd27: tx_fifo_data = "S";
                        6'd28: tx_fifo_data = " ";
                        6'd29: tx_fifo_data = 8'h0D;
                        6'd30: tx_fifo_data = 8'h0A;

                        default: tx_fifo_data = 8'h00;
                    endcase
                end

                // "ERROR: Unknown command\r\n"

                MESSAGE_INVALID: begin
                    case (index)
                        6'd0:  tx_fifo_data = "E";
                        6'd1:  tx_fifo_data = "R";
                        6'd2:  tx_fifo_data = "R";
                        6'd3:  tx_fifo_data = "O";
                        6'd4:  tx_fifo_data = "R";
                        6'd5:  tx_fifo_data = ":";
                        6'd6:  tx_fifo_data = " ";
                        6'd7:  tx_fifo_data = "U";
                        6'd8:  tx_fifo_data = "n";
                        6'd9:  tx_fifo_data = "k";
                        6'd10: tx_fifo_data = "n";
                        6'd11: tx_fifo_data = "o";
                        6'd12: tx_fifo_data = "w";
                        6'd13: tx_fifo_data = "n";
                        6'd14: tx_fifo_data = " ";
                        6'd15: tx_fifo_data = "c";
                        6'd16: tx_fifo_data = "o";
                        6'd17: tx_fifo_data = "m";
                        6'd18: tx_fifo_data = "m";
                        6'd19: tx_fifo_data = "a";
                        6'd20: tx_fifo_data = "n";
                        6'd21: tx_fifo_data = "d";
                        6'd22: tx_fifo_data = 8'h0D;
                        6'd23: tx_fifo_data = 8'h0A;
                        default: tx_fifo_data = 8'h00;
                    endcase
                end

                default: begin
                    tx_fifo_data     = 8'h00;
                    tx_fifo_write_en = 1'b0;
                end

            endcase
        end
    end

    assign message_ready = (state == idle);
      
           
            
endmodule
