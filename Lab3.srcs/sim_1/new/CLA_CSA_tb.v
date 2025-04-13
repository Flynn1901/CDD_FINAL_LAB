`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/13 22:55:14
// Design Name: 
// Module Name: CLA_CSA_tb
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


module CLA_CSA_tb();
// Parameters
    parameter CSA_WIDTH = 32;
    parameter CLA_WIDTH = 8;
    
    // Inputs
    reg [CSA_WIDTH-1:0] iopA;
    reg [CSA_WIDTH-1:0] iopB;
    reg iCin;
    
    // Outputs
    wire [CSA_WIDTH-1:0] oSum;
    wire oCout;
    
    // Expected results for checking
    reg [CSA_WIDTH:0] expected_result;
    
    // Instantiate the Unit Under Test (UUT)
    CSA_CLA #(
        .CSA_WIDTH(CSA_WIDTH),
        .CLA_WIDTH(CLA_WIDTH)
    ) uut (
        .iopA(iopA),
        .iopB(iopB),
        .iCin(iCin),
        .oSum(oSum),
        .oCout(oCout)
    );
    
    // Clock generation
    reg clk = 0;
    always #5 clk = ~clk;
    
    // Simulation time
    initial begin
        
        // Initialize Inputs
        iopA = 0;
        iopB = 0;
        iCin = 0;
        
        // Test Case 1: Basic addition without carry in
        #10;
        iopA = 32'h12345678;
        iopB = 32'h87654321;
        iCin = 0;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 1");
        
        // Test Case 2: Addition with carry in
        #10;
        iopA = 32'h12345678;
        iopB = 32'h87654321;
        iCin = 1;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 2");
        
        // Test Case 3: Addition resulting in overflow
        #10;
        iopA = 32'hFFFFFFFF;
        iopB = 32'h00000001;
        iCin = 0;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 3");
        
        // Test Case 4: Addition with carry in resulting in overflow
        #10;
        iopA = 32'hFFFFFFFF;
        iopB = 32'h00000000;
        iCin = 1;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 4");
        
        // Test Case 5: Random values
        #10;
        iopA = 32'h3A7B59C2;
        iopB = 32'h549D8E37;
        iCin = 0;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 5");
        
        // Test Case 6: Zero + Zero
        #10;
        iopA = 32'h00000000;
        iopB = 32'h00000000;
        iCin = 0;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 6");
        
        // Test Case 7: Boundary condition - all 1's
        #10;
        iopA = 32'hFFFFFFFF;
        iopB = 32'hFFFFFFFF;
        iCin = 1;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 7");
        
        // Test Case 8: Testing individual CLA blocks
        // This tests specifically across block boundaries
        #10;
        iopA = 32'h000000FF; // Will cause carry from first block
        iopB = 32'h00000001;
        iCin = 0;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 8");
        
        // Test Case 9: Testing carries between blocks
        #10;
        iopA = 32'h0000FF00; // Will cause carry from second block
        iopB = 32'h00000100;
        iCin = 0;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 9");
        
        // Test Case 10: Additional test for chains of carries
        #10;
        iopA = 32'h00FFFFFF; // Will cause chain of carries
        iopB = 32'h00000001;
        iCin = 0;
        expected_result = iopA + iopB + iCin;
        #10;
        check_result("Test Case 10");
        
        // End simulation
        #10;
        $display("All tests completed");
        $finish;
    end
    
    // Task to check the result
    task check_result;
        input [100:0] test_name;
        begin
            if ({oCout, oSum} === expected_result) begin
                $display("%s: PASSED", test_name);
                $display("A = %h, B = %h, Cin = %b", iopA, iopB, iCin);
                $display("Expected: %h, Got: %h%h (Cout, Sum)", expected_result, oCout, oSum);
            end else begin
                $display("%s: FAILED", test_name);
                $display("A = %h, B = %h, Cin = %b", iopA, iopB, iCin);
                $display("Expected: %h, Got: %h%h (Cout, Sum)", expected_result, oCout, oSum);
            end
            $display("-----------------------------------------");
        end
    endtask
endmodule
