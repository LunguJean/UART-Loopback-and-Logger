`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2026 09:03:17 PM
// Design Name: 
// Module Name: priority
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


module priority_(
        input logic inc,
        input logic dec,
        input logic res,
        
        output logic res_first,
        output logic inc_second,
        output logic dec_third
    );
    
    always_comb
    begin
        res_first = 1'b0;
        inc_second = 1'b0; 
        dec_third = 1'b0;
        
        if(res)
            res_first = 1'b1;
        else if(inc && !res)
                inc_second = 1'b1;
             else if(dec && !res && !inc)
                       dec_third = 1'b1;
    end
endmodule
