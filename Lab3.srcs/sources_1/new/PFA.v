`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/31 10:26:00
// Design Name: 
// Module Name: PFA
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


module PFA(
    input iA,
    input iB,
    input iCarry,
    output oP,
    output oG,
    output oSum
    );
    
    assign oG = iA&iB;
    assign oP = iA|iB;
    assign oSum = iA^iB^iCarry;
    
endmodule
