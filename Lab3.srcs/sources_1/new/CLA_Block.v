`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/13 21:29:58
// Design Name: 
// Module Name: CLA_Block
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


module CLA_Block#(
    parameter CLA_WIDTH = 8
    )
    (
    input iCin,
    input [CLA_WIDTH-1:0] iCLA_opA,
    input [CLA_WIDTH-1:0] iCLA_opB,
    output [CLA_WIDTH-1:0] oCLA_Sum,
    output oCout
    );
    wire Cin_0;
    wire Cin_1;
    wire Cout_0;
    wire Cout_1;
    wire [CLA_WIDTH-1:0] Sum_0;
    wire [CLA_WIDTH-1:0] Sum_1;
    
    assign Cin_0 = 0;
    assign Cin_1 = 1;
    
    CLA CLA_O(
        .iA(iCLA_opA),.iB(iCLA_opB),.iCarry(Cin_0),.oSum(Sum_0),.oCarry(Cout_0)
    );
    CLA CLA_1(
        .iA(iCLA_opA),.iB(iCLA_opB),.iCarry(Cin_1),.oSum(Sum_1),.oCarry(Cout_1)
    );
    
    assign oCout = (iCin==0)?Cout_0:Cout_1;
    assign oCLA_Sum = (iCin==0)?Sum_0:Sum_1;
    
endmodule
