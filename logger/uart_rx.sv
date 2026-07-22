`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2026 01:09:39 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx #(
    parameter DBIT = 8,
    parameter integer CLK_FREQ  = 100_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  logic clk,
    input  logic rst,
    input  logic rx,

    output logic rx_done,
    output logic [DBIT-1:0] rx_dout
);

    localparam logic [1:0] idle  = 2'b00;
    localparam logic [1:0] start = 2'b01;
    localparam logic [1:0] data  = 2'b10;
    localparam logic [1:0] stop  = 2'b11;

    localparam integer CLK_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer COUNT_BITS  = $clog2(CLK_PER_BIT);

    logic rx_sync1;
    logic rx_sync2;

    logic [1:0] state_reg, state_next;

    logic [COUNT_BITS-1:0] clock_count_reg;
    logic [COUNT_BITS-1:0] clock_count_next;

    logic [$clog2(DBIT)-1:0] n_reg, n_next;
    logic [DBIT-1:0] b_reg, b_next;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end
        else
        begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state_reg       <= idle;
            clock_count_reg <= '0;
            n_reg           <= '0;
            b_reg           <= '0;
        end
        else
        begin
            state_reg       <= state_next;
            clock_count_reg <= clock_count_next;
            n_reg           <= n_next;
            b_reg           <= b_next;
        end
    end

    always @(*)
    begin
        state_next       = state_reg;
        clock_count_next = clock_count_reg;
        n_next           = n_reg;
        b_next           = b_reg;
        rx_done          = 1'b0;

        case(state_reg)

            idle:
            begin
                clock_count_next = '0;
                n_next           = '0;

                if(rx_sync2 == 1'b0)
                    state_next = start;
            end

            start:
            begin
                if(clock_count_reg == (CLK_PER_BIT / 2) - 1)
                begin
                    clock_count_next = '0;

                    if(rx_sync2 == 1'b0)
                        state_next = data;
                    else
                        state_next = idle;
                end
                else
                begin
                    clock_count_next = clock_count_reg + 1'b1;
                end
            end

            data:
            begin
                if(clock_count_reg == CLK_PER_BIT - 1)
                begin
                    clock_count_next = '0;

                    b_next = b_reg >> 1;
                    b_next[DBIT-1] = rx_sync2;

                    if(n_reg == DBIT - 1)
                    begin
                        n_next     = '0;
                        state_next = stop;
                    end
                    else
                    begin
                        n_next = n_reg + 1'b1;
                    end
                end
                else
                begin
                    clock_count_next = clock_count_reg + 1'b1;
                end
            end

            stop:
            begin
                if(clock_count_reg == CLK_PER_BIT - 1)
                begin
                    clock_count_next = '0;

                    if(rx_sync2 == 1'b1)
                        rx_done = 1'b1;

                    state_next = idle;
                end
                else
                begin
                    clock_count_next = clock_count_reg + 1'b1;
                end
            end

            default:
            begin
                state_next       = idle;
                clock_count_next = '0;
                n_next           = '0;
                b_next           = '0;
            end

        endcase
    end

    assign rx_dout = b_reg;

endmodule
