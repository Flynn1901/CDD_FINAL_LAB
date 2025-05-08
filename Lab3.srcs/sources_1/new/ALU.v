`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/17 22:11:00
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [2:0] iCmd,
    input [31:0] iopA,
    input [31:0] iopB,
    input iCin,
    output [31:0] oSum,
    output oCout
    );
    
    reg [31:0] rOperandA;
    reg [31:0] rOperandB;
    
    reg [31:0] rSum;
    reg rCout;
    
    always@(*) begin
        rOperandA <= iopA;
        rOperandB <= iopB;
        rOperandB_Com <= ~rOperandB + 1;
    end
    
    
    
    
    
endmodule
