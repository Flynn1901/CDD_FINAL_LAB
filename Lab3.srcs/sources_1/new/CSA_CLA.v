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
    input [CSA_WIDTH-1:0] opA,
    input [CSA_WIDTH-1:0] opB,
    input Cin,
    output [CSA_WIDTH-1:0] Result,
    output Cout
    );
    wire [CLA_NUM-1:0] wCin_CLA;
    reg [CLA_WIDTH-1:0] rCLA_opA [0:CLA_GROUP-1];
    reg [CLA_WIDTH-1:0] rCLA_opB [0:CLA_GROUP-1];
    
    integer k;
    always@(*)begin
        wCin_CLA[0] = Cin;
    end
    
    integer i; 
    always@(*)begin
        for(i=0;i<CLA_GROUP;i=i+1)begin
            rCLA_opA[i] = opA[i*CLA_WIDTH +: CLA_WIDTH];
            rCLA_opB[i] = opB[i*CLA_WIDTH +: CLA_WIDTH];
        end
    end

    genvar j;
    generate
    for(j=0;j<CLA_NUM;j=j+1)begin
        CLA CLA_inst(
            .
        )
    
    end
    CLA CLA_inst(
                    .iA(iA[i]),.iB(iB[i]),.iCarry(iCarry),.oSum(oSum[i]),
                    .oP(w_oP[i]),.oG(w_oG[i])
                    
                    input wire [CLA_WIDTH-1:0] iA,iB,
    input wire                  iCarry,
    output wire [CLA_WIDTH-1:0] oSum,
    output wire                 oCarry
                );
    
endmodule
