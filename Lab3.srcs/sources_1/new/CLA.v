`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2025/03/31 10:27:40
// Design Name: 
// Module Name: CLA
// Description: 
// 8-bit CLA with 8 inst of PFA.
//////////////////////////////////////////////////////////////////////////////////


module CLA #(
    parameter CLA_WIDTH = 8
    )
    (
    input wire [CLA_WIDTH-1:0] iA,iB,
    input wire                  iCarry,
    output wire [CLA_WIDTH-1:0] oSum,
    output wire                 oCarry
    );
    
    wire [CLA_WIDTH-1:0] w_oP;
    wire [CLA_WIDTH-1:0] w_oG;   
    wire [CLA_WIDTH-2:0] w_oCarry; // Carries C1 to C7 (internal carries)
    
    // Carry Lookahead Logic
    // C1 = G0 + P0，C0
    assign w_oCarry[0] = w_oG[0] | (w_oP[0] & iCarry);
    
    // C2 = G1 + P1，G0 + P1，P0，C0
    assign w_oCarry[1] = w_oG[1] | (w_oP[1] & w_oG[0]) | (w_oP[1] & w_oP[0] & iCarry);
    
    // C3 = G2 + P2，G1 + P2，P1，G0 + P2，P1，P0，C0
    assign w_oCarry[2] = w_oG[2] | (w_oP[2] & w_oG[1]) | (w_oP[2] & w_oP[1] & w_oG[0]) | 
                        (w_oP[2] & w_oP[1] & w_oP[0] & iCarry);
    
    // C4 = G3 + P3，G2 + P3，P2，G1 + P3，P2，P1，G0 + P3，P2，P1，P0，C0
    assign w_oCarry[3] = w_oG[3] | (w_oP[3] & w_oG[2]) | (w_oP[3] & w_oP[2] & w_oG[1]) | 
                        (w_oP[3] & w_oP[2] & w_oP[1] & w_oG[0]) | 
                        (w_oP[3] & w_oP[2] & w_oP[1] & w_oP[0] & iCarry);
    
    // C5 = G4 + P4，G3 + P4，P3，G2 + P4，P3，P2，G1 + P4，P3，P2，P1，G0 + P4，P3，P2，P1，P0，C0
    assign w_oCarry[4] = w_oG[4] | (w_oP[4] & w_oG[3]) | (w_oP[4] & w_oP[3] & w_oG[2]) | 
                        (w_oP[4] & w_oP[3] & w_oP[2] & w_oG[1]) | 
                        (w_oP[4] & w_oP[3] & w_oP[2] & w_oP[1] & w_oG[0]) | 
                        (w_oP[4] & w_oP[3] & w_oP[2] & w_oP[1] & w_oP[0] & iCarry);
    
    // C6 = G5 + P5，G4 + P5，P4，G3 + P5，P4，P3，G2 + P5，P4，P3，P2，G1 + P5，P4，P3，P2，P1，G0 + P5，P4，P3，P2，P1，P0，C0
    assign w_oCarry[5] = w_oG[5] | (w_oP[5] & w_oG[4]) | (w_oP[5] & w_oP[4] & w_oG[3]) | 
                        (w_oP[5] & w_oP[4] & w_oP[3] & w_oG[2]) | 
                        (w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oG[1]) | 
                        (w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oP[1] & w_oG[0]) | 
                        (w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oP[1] & w_oP[0] & iCarry);
    
    // C7 = G6 + P6，G5 + P6，P5，G4 + P6，P5，P4，G3 + P6，P5，P4，P3，G2 + P6，P5，P4，P3，P2，G1 + P6，P5，P4，P3，P2，P1，G0 + P6，P5，P4，P3，P2，P1，P0，C0
    assign w_oCarry[6] = w_oG[6] | (w_oP[6] & w_oG[5]) | (w_oP[6] & w_oP[5] & w_oG[4]) | 
                        (w_oP[6] & w_oP[5] & w_oP[4] & w_oG[3]) | 
                        (w_oP[6] & w_oP[5] & w_oP[4] & w_oP[3] & w_oG[2]) | 
                        (w_oP[6] & w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oG[1]) | 
                        (w_oP[6] & w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oP[1] & w_oG[0]) | 
                        (w_oP[6] & w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oP[1] & w_oP[0] & iCarry);
    
    // oCarry = G7 + P7，G6 + P7，P6，G5 + P7，P6，P5，G4 + P7，P6，P5，P4，G3 + P7，P6，P5，P4，P3，G2 + P7，P6，P5，P4，P3，P2，G1 + P7，P6，P5，P4，P3，P2，P1，G0 + P7，P6，P5，P4，P3，P2，P1，P0，C0
    assign oCarry = w_oG[7] | (w_oP[7] & w_oG[6]) | (w_oP[7] & w_oP[6] & w_oG[5]) | 
                   (w_oP[7] & w_oP[6] & w_oP[5] & w_oG[4]) | 
                   (w_oP[7] & w_oP[6] & w_oP[5] & w_oP[4] & w_oG[3]) | 
                   (w_oP[7] & w_oP[6] & w_oP[5] & w_oP[4] & w_oP[3] & w_oG[2]) | 
                   (w_oP[7] & w_oP[6] & w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oG[1]) | 
                   (w_oP[7] & w_oP[6] & w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oP[1] & w_oG[0]) | 
                   (w_oP[7] & w_oP[6] & w_oP[5] & w_oP[4] & w_oP[3] & w_oP[2] & w_oP[1] & w_oP[0] & iCarry);
    
    genvar i;
    
    generate 
        for(i=0;i<CLA_WIDTH;i=i+1) begin
            if(i==0) begin
                PFA PFA_inst(
                    .iA(iA[i]),.iB(iB[i]),.iCarry(iCarry),.oSum(oSum[i]),
                    .oP(w_oP[i]),.oG(w_oG[i])
                );
            end
            else if(i==CLA_WIDTH-1) begin
                PFA PFA_inst(
                    .iA(iA[i]),.iB(iB[i]),.iCarry(w_oCarry[i-1]),.oSum(oSum[i]),
                    .oP(w_oP[i]),.oG(w_oG[i])
                );
            end
            else begin
                PFA PFA_inst(
                    .iA(iA[i]),.iB(iB[i]),.iCarry(w_oCarry[i-1]),.oSum(oSum[i]),
                    .oP(w_oP[i]),.oG(w_oG[i])
                );
            end
        end
    endgenerate
   
endmodule