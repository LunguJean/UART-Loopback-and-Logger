`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 08:38:50 PM
// Design Name: 
// Module Name: tx_controller
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




module tx_controller (
    input  logic clk,
    input  logic rst,

    input  logic [7:0] tx_fifo_dout,
    input  logic tx_fifo_empty,
    output logic tx_fifo_rd_en,

    input  logic uart_tx_done,
    output logic [7:0] uart_tx_data,
    output logic uart_tx_start
);

    localparam logic [2:0] idle = 3'b000;
    localparam logic [2:0] read_fifo  = 3'b001;
    localparam logic [2:0] wait_data  = 3'b010;
    localparam logic [2:0] save_data  = 3'b011;
    localparam logic [2:0] send_uart  = 3'b100;
    localparam logic [2:0] wait_uart  = 3'b101;

    logic [2:0] state;
    logic [2:0] state_next;

    logic [7:0] data_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= idle;
            data_reg <= 8'h00;
        end
        else begin
            state <= state_next;

            if (state == save_data)
                data_reg <= tx_fifo_dout;
        end
    end

    always_comb begin
        state_next = state;

        case (state)

            idle: begin
                if (!tx_fifo_empty)
                    state_next = read_fifo;
            end

            read_fifo: begin
                state_next = wait_data;
            end

            wait_data: begin
                state_next = save_data;
            end

            save_data: begin
                state_next = send_uart;
            end

            send_uart: begin
                state_next = wait_uart;
            end

            wait_uart: begin
                if (uart_tx_done)
                    state_next = idle;
            end

            default: begin
                state_next = idle;
            end

        endcase
    end

    always_comb begin
        tx_fifo_rd_en = 1'b0;
        uart_tx_start = 1'b0;
        uart_tx_data  = data_reg;

        case (state)

            read_fifo: begin
                tx_fifo_rd_en = 1'b1;
            end

            send_uart: begin
                uart_tx_start = 1'b1;
                uart_tx_data  = data_reg;
            end

            default: begin
                tx_fifo_rd_en = 1'b0;
                uart_tx_start = 1'b0;
            end

        endcase
    end


endmodule
