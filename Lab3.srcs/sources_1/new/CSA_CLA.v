`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/13 16:53:12
// Design Name: 
// Module Name: CSA_CLA
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


module CSA_CLA#(
    parameter CSA_WIDTH = 32,
    parameter CLA_WIDTH = 8,
    parameter CLA_NUM = (CSA_WIDTH/CLA_WIDTH)-1,
    parameter CLA_GROUP = CSA_WIDTH/CLA_WIDTH
    )(
    input [CSA_WIDTH-1:0] iopA,
    input [CSA_WIDTH-1:0] iopB,
    input iCin,
    output [CSA_WIDTH-1:0] oSum,
    output oCout
    );
    reg [CLA_WIDTH-1:0] rCLA_opA [0:CLA_GROUP-1];
    reg [CLA_WIDTH-1:0] rCLA_opB [0:CLA_GROUP-1];
    wire [CSA_WIDTH-1:0] wCLA_Sum;
    wire wCLA_Cout_01;
    wire wCLA_Cout_12;
    wire wCLA_Cout_23;
    
    integer i; 
    always@(*)begin
        for(i=0;i<CLA_GROUP;i=i+1)begin
            rCLA_opA[i] = iopA[i*CLA_WIDTH +: CLA_WIDTH];
            rCLA_opB[i] = iopB[i*CLA_WIDTH +: CLA_WIDTH];
        end
    end
    
    CLA CLA_inst_0(
        .iA(rCLA_opA[0]),.iB(rCLA_opA[0]),.iCarry(iCin),.oSum(wCLA_Sum[7:0]),.oCarry(rCLA_Cout_01)
    );
    CLA_Block CLA_Block_inst_1(
        .iCLA_opA(rCLA_opA[1]),.iCLA_opB(rCLA_opB[1]),.iCin(wCLA_Cout_01),.oCLA_Sum(wCLA_Sum[15:8]),.oCout(rCLA_Cout_12)
    );
    CLA_Block CLA_Block_inst_2(
        .iCLA_opA(rCLA_opA[2]),.iCLA_opB(rCLA_opB[2]),.iCin(wCLA_Cout_12),.oCLA_Sum(wCLA_Sum[23:16]),.oCout(rCLA_Cout_23)
    );
    CLA_Block CLA_Block_inst_3(
        .iCLA_opA(rCLA_opA[3]),.iCLA_opB(rCLA_opB[3]),.iCin(wCLA_Cout_23),.oCLA_Sum(wCLA_Sum[31:24]),.oCout(oCout)
    );
    
    assign oSum = wCLA_Sum;
endmodule
