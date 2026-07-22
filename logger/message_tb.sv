`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/22/2026 11:33:34 PM
// Design Name: 
// Module Name: message_tb
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




module message_tb;

logic clk;
logic rst;

logic message_inc;
logic message_dec;
logic message_res;
logic message_status;
logic message_help;
logic message_invalid;

logic [3:0] hex3;
logic [3:0] hex2;
logic [3:0] hex1;
logic [3:0] hex0;

logic tx_fifo_full;
logic [7:0] tx_fifo_data;
logic tx_fifo_write_en;

logic message_ready;

message DUT(
    .clk(clk),
    .rst(rst),

    .message_inc(message_inc),
    .message_dec(message_dec),
    .message_res(message_res),
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

always #5 clk = ~clk;

always @(posedge clk)
begin
    if(tx_fifo_write_en)
        $display("%0t  %c   0x%02h",
                 $time,
                 tx_fifo_data,
                 tx_fifo_data);
end

initial
begin

    clk = 0;
    rst = 1;

    message_inc = 0;
    message_dec = 0;
    message_res = 0;
    message_status = 0;
    message_help = 0;
    message_invalid = 0;

    tx_fifo_full = 0;

    hex3 = 4'h1;
    hex2 = 4'hA;
    hex1 = 4'h2;
    hex0 = 4'hF;

    #20;
    rst = 0;

    // STATUS

    @(posedge clk);
    message_status = 1;

    @(posedge clk);
    message_status = 0;

    wait(message_ready);

    #50;

    // INC

    @(posedge clk);
    message_inc = 1;

    @(posedge clk);
    message_inc = 0;

    wait(message_ready);

    #50;

    // DEC

    @(posedge clk);
    message_dec = 1;

    @(posedge clk);
    message_dec = 0;

    wait(message_ready);

    #50;

    // RESET

    @(posedge clk);
    message_res = 1;

    @(posedge clk);
    message_res = 0;

    wait(message_ready);

    #50;

    // HELP

    @(posedge clk);
    message_help = 1;

    @(posedge clk);
    message_help = 0;

    wait(message_ready);

    #50;

    // INVALID

    @(posedge clk);
    message_invalid = 1;

    @(posedge clk);
    message_invalid = 0;

    wait(message_ready);

    #100;

    $finish;

end

endmodule
