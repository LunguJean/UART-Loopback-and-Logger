`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 05:26:00 PM
// Design Name: 
// Module Name: controller
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


module controller(
    input logic clk,
    input logic rst,
    
    input logic cmd_inc,
    input logic cmd_dec,
    input logic cmd_res,
    input logic cmd_status,
    input logic cmd_help,
    input logic cmd_invalid,
    
    input logic inc_valid,
    input logic dec_valid,
    input logic reset_valid,
    
    //catre message
    input logic message_ready,
    //catre controller si command
    output logic controller_ready,
    
    output logic counter_inc,
    output logic counter_dec,
    output logic counter_res,
    
    
    output logic message_inc,
    output logic message_dec,
    output logic message_res,
    output logic message_status,
    output logic message_help,
    output logic message_invalid
    );
    
    localparam logic idle = 1'b0;
    localparam logic send = 1'b1;
    
    logic state, state_next;
    
    
    //pentru fiecare comand se produce cate un eveniment
    localparam logic [2:0] no_event = 3'b000;
    localparam logic [2:0] event_inc = 3'b001;
    localparam logic [2:0] event_dec = 3'b010;
    localparam logic [2:0] event_res = 3'b011;
    localparam logic [2:0] event_status = 3'b100;
    localparam logic [2:0] event_help = 3'b101;
    localparam logic [2:0] event_invalid = 3'b110;

    logic [2:0] event_reg;
    logic [2:0] selected_event;

    logic command;
    
    //starile
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            state <= idle;
        else 
            state <= state_next;
    end
    
    //evenimentele
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            event_reg <= no_event; 
        else
        begin
            if((state == idle) && command)
                event_reg <= selected_event;
            else if((state == send) && message_ready)
                event_reg <= no_event;
        end
    end
    
    
    // selectarea evenimentului si prioritatile
    always @(*)
    begin
        selected_event = no_event;
        command = 1'b0;
        
        //reset
        if (cmd_res || reset_valid) begin
            selected_event   = event_res;
            command = 1'b1;
        end

       //incrementare prin UART
        else if (cmd_inc) begin
            selected_event   = event_inc;
            command = 1'b1;
        end

        //decrementare prin UART
        else if (cmd_dec) begin
            selected_event   = event_dec;
            command = 1'b1;
        end

        //incrementare buton
        else if (inc_valid) begin
            selected_event   = event_inc;
            command = 1'b1;
        end

        //decrementare buton
        else if (dec_valid) begin
            selected_event   = event_dec;
            command = 1'b1;
        end

        //status
        else if (cmd_status) begin
            selected_event   = event_status;
            command = 1'b1;
        end
        
        //help
        else if (cmd_help) begin
            selected_event   = event_help;
            command = 1'b1;
        end

        //invalid
        else if (cmd_invalid) begin
            selected_event   = event_invalid;
            command = 1'b1;
        end
    
    
    end
    
    always @(*)
    begin
        state_next = state;
        case(state)
            idle:
            begin
                if(command)
                    state_next = send;
            end
            
            send:
            begin
                if(message_ready)
                    state_next = idle;
            end
            
            default: 
            begin
                state_next = idle;
            end
            
        endcase    
    end
    
    //semnalul catre command
    //atunci cand este activa o comanda
    
    assign controller_ready = (state == idle);
    
    //counter
    always @(*)
    begin
        counter_inc = 1'b0;
        counter_dec = 1'b0;
        counter_res = 1'b0;
        
        if((state == idle) && command)
        begin
            if(selected_event == event_inc)
                counter_inc = 1'b1;
            else if(selected_event == event_dec)
                    counter_dec = 1'b1;
            else if(selected_event == event_res)
                    counter_res = 1'b1;
                    
        end
    end
    
    //message
    always @(*)
    begin
        message_inc     = 1'b0;
        message_dec     = 1'b0;
        message_res     = 1'b0;
        message_status  = 1'b0;
        message_help    = 1'b0;
        message_invalid = 1'b0;
        
        if((state == send) && message_ready)
        begin
            if(event_reg == event_inc)
                message_inc = 1'b1;
            else if(event_reg == event_dec)
                    message_dec = 1'b1;
            else if(event_reg == event_res)
                    message_res = 1'b1;
            else if(event_reg == event_status)
                    message_status = 1'b1;
            else if(event_reg == event_help)
                    message_help = 1'b1;
            else if(event_reg == event_invalid)
                    message_invalid = 1'b1;
                        
        end
    end
    
    
    
    
    
    
    
endmodule
