`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2025/04/13 16:53:12
// Design Name: 
// Module Name: CSA_CLA
// Description: 
// Parameterizable Carry Select Adder with Carry Lookahead blocks
//////////////////////////////////////////////////////////////////////////////////

module CSA_CLA#(
    parameter ADDER_WIDTH = 64,
    parameter CLA_WIDTH = 8,  // Fixed at 8 due to CLA implementation
    parameter CLA_GROUP = (ADDER_WIDTH + CLA_WIDTH - 1) / CLA_WIDTH  // Ceiling division
    )(
    input [ADDER_WIDTH-1:0] iopA,
    input [ADDER_WIDTH-1:0] iopB,
    input iCin,
    output [ADDER_WIDTH-1:0] oSum,
    output oCout
    );
    
    // Arrays to hold operands, sums, and carry signals for each CLA block
    wire [CLA_WIDTH-1:0] rCLA_opA [0:CLA_GROUP-1];
    wire [CLA_WIDTH-1:0] rCLA_opB [0:CLA_GROUP-1];
    wire [CLA_WIDTH-1:0] wCLA_Sum [0:CLA_GROUP-1];
    wire [CLA_GROUP:0] wCLA_Cout;  // One more for the final carry output
    
    // Split input operands into CLA_WIDTH blocks
    genvar i;
    generate
        for (i = 0; i < CLA_GROUP; i = i + 1) begin : g_split_operands
            if (i * CLA_WIDTH + CLA_WIDTH <= ADDER_WIDTH) begin
                // Full CLA_WIDTH block
                assign rCLA_opA[i] = iopA[i*CLA_WIDTH +: CLA_WIDTH];
                assign rCLA_opB[i] = iopB[i*CLA_WIDTH +: CLA_WIDTH];
            end
            else begin
                // Partial block for the last block if ADDER_WIDTH is not a multiple of CLA_WIDTH
                localparam LAST_BLOCK_WIDTH = ADDER_WIDTH - i*CLA_WIDTH;
                // Take the remaining bits from the inputs
                assign rCLA_opA[i][LAST_BLOCK_WIDTH-1:0] = iopA[ADDER_WIDTH-1:i*CLA_WIDTH];
                assign rCLA_opB[i][LAST_BLOCK_WIDTH-1:0] = iopB[ADDER_WIDTH-1:i*CLA_WIDTH];
                // Pad with zeros for any remaining bits in the CLA_WIDTH
                assign rCLA_opA[i][CLA_WIDTH-1:LAST_BLOCK_WIDTH] = {(CLA_WIDTH-LAST_BLOCK_WIDTH){1'b0}};
                assign rCLA_opB[i][CLA_WIDTH-1:LAST_BLOCK_WIDTH] = {(CLA_WIDTH-LAST_BLOCK_WIDTH){1'b0}};
            end
        end
    endgenerate
    
    // Chain of carries
    assign wCLA_Cout[0] = iCin;
    
    // Generate CLA/CLA_Block instances
    generate
        for (i = 0; i < CLA_GROUP; i = i + 1) begin : g_cla_instances
            if (i == 0) begin
                // First block uses direct CLA
                CLA CLA_inst (
                    .iA(rCLA_opA[i]),
                    .iB(rCLA_opB[i]),
                    .iCarry(wCLA_Cout[i]),
                    .oSum(wCLA_Sum[i]),
                    .oCarry(wCLA_Cout[i+1])
                );
            end
            else begin
                // Subsequent blocks use CLA_Block
                CLA_Block CLA_Block_inst (
                    .iCLA_opA(rCLA_opA[i]),
                    .iCLA_opB(rCLA_opB[i]),
                    .iCin(wCLA_Cout[i]),
                    .oCLA_Sum(wCLA_Sum[i]),
                    .oCout(wCLA_Cout[i+1])
                );
            end
        end
    endgenerate
    
    // Combine block sums into the final sum
    generate
        for (i = 0; i < CLA_GROUP; i = i + 1) begin : g_combine_sums
            if (i * CLA_WIDTH + CLA_WIDTH <= ADDER_WIDTH) begin
                // Full CLA_WIDTH block
                assign oSum[i*CLA_WIDTH +: CLA_WIDTH] = wCLA_Sum[i];
            end
            else begin
                // Partial block - only take the bits we need for the final output
                localparam LAST_BLOCK_WIDTH = ADDER_WIDTH - i*CLA_WIDTH;
                assign oSum[ADDER_WIDTH-1:i*CLA_WIDTH] = wCLA_Sum[i][LAST_BLOCK_WIDTH-1:0];
            end
        end
    endgenerate
    
    // Assign output carry
    assign oCout = wCLA_Cout[CLA_GROUP];
    
endmodule