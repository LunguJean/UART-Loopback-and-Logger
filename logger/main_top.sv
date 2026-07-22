`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2026 11:37:30 PM
// Design Name: 
// Module Name: main_top
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


module main_top#(
        parameter integer CLK_FREQ = 100_000_000,
        parameter integer BAUD_RATE = 9600,
        parameter integer TIMER_FINAL_VALUE = 1_000_000
)(
    input logic clk,
    input logic rst,
    
    input logic rx_pin,
    output logic tx_pin,
    
    input logic inc_button,
    input logic dec_button,
    input logic reset_button,
    
    output logic [15:0] led
//    output logic [6:0] seg,
//    output logic [7:0] an
    );
    
    //butoane
    logic inc_sync,timer_done_inc, timer_reset_inc,inc_db,inc_pulse,inc_valid;
    logic dec_sync,timer_done_dec, timer_reset_dec,dec_db,dec_pulse,dec_valid;
    logic reset_sync,timer_done_reset, timer_reset_reset,reset_db,reset_pulse,reset_valid; 
    
    logic [15:0] count;
    
    
//    // semnalele pentru afisajul cu 7 segmente
//    logic [3:0] ones;
//    logic [3:0] tens;
//    logic [3:0] hundreds;
//    logic [3:0] thousands;
//    logic [3:0] ten_thousands;

//    logic [2:0] sel;
//    logic [3:0] current_digit;
    
    
    //uart rx
    logic [7:0] uart_rx_data;
    logic uart_rx_done;
    
    uart_rx #(
        .DBIT(8),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) UART_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx_pin),
        .rx_done(uart_rx_done),
        .rx_dout(uart_rx_data)
    );
    
    //rx_fifo
    logic [7:0] rx_fifo_dout;
    logic rx_fifo_write_en;
    logic rx_fifo_read_en;
    logic rx_fifo_full;
    logic rx_fifo_empty;
    
    assign rx_fifo_write_en = uart_rx_done && (!rx_fifo_full);
    
    rx_fifo RX_FIFO (
        .clk(clk),
        .srst(rst),
        .din(uart_rx_data),
        .wr_en(rx_fifo_write_en),
        .rd_en(rx_fifo_read_en),
        .dout(rx_fifo_dout),
        .full(rx_fifo_full),
        .empty(rx_fifo_empty)
    );
    
    //command
    logic cmd_inc;
    logic cmd_dec;
    logic cmd_res;
    logic cmd_status;
    logic cmd_help;
    logic cmd_invalid;

    logic controller_ready;
    command COMMAND (
        .clk(clk),
        .rst(rst),
        .fifo_data(rx_fifo_dout),
        .fifo_empty(rx_fifo_empty),
        .fifo_read_en(rx_fifo_read_en),
        .controller_ready (controller_ready),

        .cmd_inc(cmd_inc),
        .cmd_dec(cmd_dec),
        .cmd_res(cmd_res),
        .cmd_status(cmd_status),
        .cmd_help(cmd_help),
        .cmd_invalid(cmd_invalid)
    );
    //INC 
    sync sync_inc(
        .clk(clk),
        .in(inc_button),
        .out(inc_sync)
    );
    
    debouncer debouncer_inc(
        .clk(clk),
        .push(inc_sync),
        .timer_done(timer_done_inc),
        .timer_reset(timer_reset_inc),
        .debounced(inc_db)
    
    );
    
    debouncer_timer#(
            .FINAL_VALUE(TIMER_FINAL_VALUE)
 )debouncer_timer_inc(
        .clk(clk),
        .timer_reset(timer_reset_inc),
        .timer_done(timer_done_inc)
    );
    
    edge_detector edge_inc(
        .clk(clk),
        .level(inc_db),
        .p_level(inc_pulse)
    );
    
    //DEC
    sync sync_dec(
        .clk(clk),
        .in(dec_button),
        .out(dec_sync)
    );
    
    debouncer debouncer_dec(
        .clk(clk),
        .push(dec_sync),
        .timer_done(timer_done_dec),
        .timer_reset(timer_reset_dec),
        .debounced(dec_db)
    
    );
    
    debouncer_timer#(
            .FINAL_VALUE(TIMER_FINAL_VALUE)
 )debouncer_timer_dec(
        .clk(clk),
        .timer_reset(timer_reset_dec),
        .timer_done(timer_done_dec)
    );
    edge_detector edge_dec(
        .clk(clk),
        .level(dec_db),
        .p_level(dec_pulse)
    );
    
    //RESET
    sync sync_reset(
        .clk(clk),
        .in(reset_button),
        .out(reset_sync)
    );
    
    debouncer debouncer_reset(
        .clk(clk),
        .push(reset_sync),
        .timer_done(timer_done_reset),
        .timer_reset(timer_reset_reset),
        .debounced(reset_db)
    
    );
    
    debouncer_timer#(
            .FINAL_VALUE(TIMER_FINAL_VALUE)
 )debouncer_timer_reset(
        .clk(clk),
        .timer_reset(timer_reset_reset),
        .timer_done(timer_done_reset)
    );
    
    
    edge_detector edge_reset(
        .clk(clk),
        .level(reset_db),
        .p_level(reset_pulse)
    );
    
    //Priority pentru cele 3 butoane
    priority_ priority__(
        .inc(inc_pulse),
        .dec(dec_pulse),
        .res(reset_pulse),

        .res_first(reset_valid),
        .inc_second(inc_valid),
        .dec_third(dec_valid)
    );
    
    //controll
    logic counter_inc;
    logic counter_dec;
    logic counter_res;
    
    
    logic message_inc;
    logic message_dec;
    logic message_res;
    logic message_status;
    logic message_help;
    logic message_invalid;
    
    logic message_ready;
    
    controller CONTROLLER(
         .clk(clk),
        .rst(rst),
        
        .cmd_inc(cmd_inc),
        .cmd_dec(cmd_dec),
        .cmd_res(cmd_res),
        .cmd_status(cmd_status),
        .cmd_help(cmd_help),
        .cmd_invalid(cmd_invalid),

        .inc_valid(inc_valid),
        .dec_valid(dec_valid),
        .reset_valid(reset_valid),

        .message_ready(message_ready),

        .controller_ready(controller_ready),

        .counter_inc(counter_inc),
        .counter_dec(counter_dec),
        .counter_res(counter_res),

        .message_inc(message_inc),
        .message_dec(message_dec),
        .message_res(message_res),
        .message_status(message_status),
        .message_help(message_help),
        .message_invalid(message_invalid)
    );
    
    
    //contorul
    FSM_contor fsm_inst(
        .clk(clk),
        .rst(rst),
        .value_inc(counter_inc),
        .value_dec(counter_dec),
        .value_reset(counter_res),

        .count(count),
        .led(led)
    );
    
    //b2h
    logic [3:0] hex3;
    logic [3:0] hex2;
    logic [3:0] hex1;
    logic [3:0] hex0;

    b2h B2H (
        .binary(count),

        .hex3(hex3),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0)
    );
    
    
    //message
    logic [7:0] tx_fifo_data;
    logic tx_fifo_write_en;
    logic tx_fifo_full;
    
    logic message_inc_delay;
    logic message_dec_delay;
    logic message_res_delay;
    
    always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        message_inc_delay <= 1'b0;
        message_dec_delay <= 1'b0;
        message_res_delay <= 1'b0;
    end
    else begin
        message_inc_delay <= message_inc;
        message_dec_delay <= message_dec;
        message_res_delay <= message_res;
    end
    end
    
    message MESSAGE (

        .clk(clk),
        .rst(rst),

        .message_inc(message_inc_delay),
        .message_dec(message_dec_delay),
        .message_res(message_res_delay),
        .message_status(message_status),
        .message_help(message_help),
        .message_invalid(message_invalid),

        .hex3(hex3),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0),

        .tx_fifo_full(tx_fifo_full),

        .tx_fifo_data(tx_fifo_data),
        .tx_fifo_write_en(tx_fifo_write_en),

        .message_ready(message_ready)
    );
    
    //tx_fifo
    
    logic [7:0] tx_fifo_dout;
    logic tx_fifo_read_en;
    logic tx_fifo_empty;
    
    tx_fifo TX_FIFO(
        .clk(clk),
        .rst(rst),

        .din(tx_fifo_data),
        .wr_en(tx_fifo_write_en),

        .rd_en(tx_fifo_read_en),

        .dout(tx_fifo_dout),

        .full(tx_fifo_full),
        .empty(tx_fifo_empty)
    );
    
    //tx_controller
    logic [7:0] uart_tx_data;
    logic uart_tx_start;
    logic uart_tx_done;
    tx_controller TX_CONTROLLER(
        
        .clk(clk),
        .rst(rst),

        .tx_fifo_dout(tx_fifo_dout),
        .tx_fifo_empty(tx_fifo_empty),
        .tx_fifo_rd_en(tx_fifo_read_en),

        .uart_tx_done(uart_tx_done),

        .uart_tx_data(uart_tx_data),
        .uart_tx_start(uart_tx_start)
    );
    
    uart_tx UART_TX (

        .clk(clk),
        .rst(rst),

        .tx_start(uart_tx_start),
        .tx_din(uart_tx_data),

        .tx_done(uart_tx_done),

        .tx(tx_pin)
    );
//    binary_to_decimal b2d(
//        .bin(count),
//        .ten_thousands(ten_thousands),
//        .thousands(thousands),
//        .hundreds(hundreds),
//        .tens(tens),
//        .ones(ones)
//    );
    
//    refresh REFRESH(
//        .clk(clk),
//        .sel(sel)
//    );
    
//    mux MUX(
//        .sel(sel),
//        .ones(ones),
//        .tens(tens),
//        .hundreds(hundreds),
//        .thousands(thousands),
//        .ten_thousands(ten_thousands),
//        .digit(current_digit)
//    );
    
//    seg_decodor SEG_DECODOR(
//        .digit(current_digit),
//        .seg(seg)
//    );
    
//    anode_selector ANODE_SELECTOR(
//        .sel(sel),
//        .an(an)
//    );
    
endmodule
