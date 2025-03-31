`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: CLA_tb
// Description: Testbench for 8-bit CLA (Carry Lookahead Adder)
//////////////////////////////////////////////////////////////////////////////////

module CLA_tb();
    // Parameters
    localparam CLA_WIDTH = 8;
    
    // Inputs
    reg [CLA_WIDTH-1:0] iA;
    reg [CLA_WIDTH-1:0] iB;
    reg iCarry;
    
    // Outputs
    wire [CLA_WIDTH-1:0] oSum;
    wire oCarry;
    
    // Expected outputs for verification
    reg [CLA_WIDTH:0] expected_result;
    
    // Instantiate the CLA module
    CLA #(
        .CLA_WIDTH(CLA_WIDTH)
    ) dut (
        .iA(iA),
        .iB(iB),
        .iCarry(iCarry),
        .oSum(oSum),
        .oCarry(oCarry)
    );
    
    // Variables for test case management
    integer test_case = 0;
    integer error_count = 0;
    integer i=0;
    // Task to check results
    task check_result;
        input [31:0] tc_num;
        begin
            // Calculate expected results
            expected_result = iA + iB + iCarry;
            
            // Add a small delay for signals to propagate
            #1;
            
            // Check the actual results against expected
            if (oSum !== expected_result[CLA_WIDTH-1:0] || oCarry !== expected_result[CLA_WIDTH]) begin
                $display("Error at test case %0d:", tc_num);
                $display("  Inputs: iA = %b (%h), iB = %b (%h), iCarry = %b", 
                         iA, iA, iB, iB, iCarry);
                $display("  Expected: oSum = %b (%h), oCarry = %b", 
                         expected_result[CLA_WIDTH-1:0], expected_result[CLA_WIDTH-1:0], expected_result[CLA_WIDTH]);
                $display("  Actual: oSum = %b (%h), oCarry = %b", 
                         oSum, oSum, oCarry);
                error_count = error_count + 1;
            end else begin
                $display("Test case %0d passed: %h + %h + %b = %h, carry = %b", 
                         tc_num, iA, iB, iCarry, oSum, oCarry);
            end
        end
    endtask
    
    // Stimulus process
    initial begin
        // Initialize inputs
        iA = 0;
        iB = 0;
        iCarry = 0;
        
        // Display header
        $display("Starting 8-bit CLA Testbench");
        $display("--------------------------------------------------");
        
        // Wait for global reset
        #10;
        
        // Test case 1: Basic addition without carry in
        test_case = 1;
        iA = 8'h03;
        iB = 8'h05;
        iCarry = 0;
        #10;
        check_result(test_case);
        
        // Test case 2: Addition with carry in
        test_case = 2;
        iA = 8'h03;
        iB = 8'h05;
        iCarry = 1;
        #10;
        check_result(test_case);
        
        // Test case 3: Addition with carry out
        test_case = 3;
        iA = 8'hFF;
        iB = 8'h01;
        iCarry = 0;
        #10;
        check_result(test_case);
        
        // Test case 4: Addition with carry in and carry out
        test_case = 4;
        iA = 8'hFF;
        iB = 8'h00;
        iCarry = 1;
        #10;
        check_result(test_case);
        
        // Test case 5: Random mid-range values
        test_case = 5;
        iA = 8'h37;
        iB = 8'h45;
        iCarry = 0;
        #10;
        check_result(test_case);
        
        // Test case 6: Values that exercise multiple carry paths
        test_case = 6;
        iA = 8'h7F;
        iB = 8'h01;  // Should result in carries propagating
        iCarry = 0;
        #10;
        check_result(test_case);
        
        // Test case 7: Check operation across byte boundary
        test_case = 7;
        iA = 8'h80;
        iB = 8'h80;  // Result should be 0x100 (overflow)
        iCarry = 0;
        #10;
        check_result(test_case);
        
        // Test case 8: Maximum values without carry in
        test_case = 8;
        iA = 8'hFF;
        iB = 8'hFF;
        iCarry = 0;
        #10;
        check_result(test_case);
        
        // Test case 9: Maximum values with carry in
        test_case = 9;
        iA = 8'hFF;
        iB = 8'hFF;
        iCarry = 1;
        #10;
        check_result(test_case);
        
        // Test case 10: Zero addition
        test_case = 10;
        iA = 8'h00;
        iB = 8'h00;
        iCarry = 0;
        #10;
        check_result(test_case);
        
        // Test additional cases with patterns that exercise the carry chain
        // Test case 11: Alternating bits
        test_case = 11;
        iA = 8'h55;  // 01010101
        iB = 8'hAA;  // 10101010
        iCarry = 0;
        #10;
        check_result(test_case);
        
        // Test case 12: Alternating bits with carry
        test_case = 12;
        iA = 8'h55;  // 01010101
        iB = 8'hAA;  // 10101010
        iCarry = 1;
        #10;
        check_result(test_case);
        
        // Test cases with incrementing values
        for (i = 0; i < 8; i = i + 1) begin
            test_case = 13 + i;
            iA = 8'h10 + i*8;
            iB = 8'h20 + i*4;
            iCarry = (i % 2) ? 1'b1 : 1'b0; // Use conditional operator instead of modulus
            #10;
            check_result(test_case);
        end
        
        // Report final test results
        $display("--------------------------------------------------");
        if (error_count == 0) begin
            $display("All test cases passed!");
        end else begin
            $display("%0d test cases failed out of %0d total tests.", error_count, test_case);
        end
        $display("--------------------------------------------------");
        
        $finish;
    end
    
endmodule