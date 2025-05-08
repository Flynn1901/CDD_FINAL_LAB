`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2025/04/14
// Design Name: 
// Module Name: CLA_Block_tb
// Description: 
// Testbench for 8-bit CLA_Block module
//////////////////////////////////////////////////////////////////////////////////

module CLA_Block_tb();

    // Parameters
    parameter CLA_WIDTH = 8;
    parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)
    
    // Testbench signals
    reg                  clk;
    reg                  rst;
    reg                  iCin;
    reg [CLA_WIDTH-1:0]  iCLA_opA;
    reg [CLA_WIDTH-1:0]  iCLA_opB;
    wire [CLA_WIDTH-1:0] oCLA_Sum;
    wire                 oCout;
    
    // Expected outputs for verification
    reg [CLA_WIDTH-1:0]  expected_sum;
    reg                  expected_cout;
    
    // Instantiate the CLA_Block module
    CLA_Block #(
        .CLA_WIDTH(CLA_WIDTH)
    ) DUT (
        .iCin(iCin),
        .iCLA_opA(iCLA_opA),
        .iCLA_opB(iCLA_opB),
        .oCLA_Sum(oCLA_Sum),
        .oCout(oCout)
    );
    
    // Clock generation
    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Test scenario counter
    integer test_case;
    integer errors;
    
    // Test initialization
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        iCin = 0;
        iCLA_opA = 0;
        iCLA_opB = 0;
        test_case = 0;
        errors = 0;
        
        // Reset sequence
        #(CLK_PERIOD*2);
        rst = 0;
        #(CLK_PERIOD);
        
        // Display test header
        $display("Starting CLA_Block Testbench");
        $display("----------------------------------------");
        $display("Test Case | iCin | iCLA_opA | iCLA_opB | Expected Sum | oCLA_Sum | Expected Cout | oCout | Result");
        $display("----------------------------------------");
        
        // Test Case 1: Simple addition with iCin = 0
        test_case = 1;
        iCin = 0;
        iCLA_opA = 8'h05;  // 5
        iCLA_opB = 8'h03;  // 3
        expected_sum = 8'h08;  // 8
        expected_cout = 0;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 2: Simple addition with iCin = 1
        test_case = 2;
        iCin = 1;
        iCLA_opA = 8'h05;  // 5
        iCLA_opB = 8'h03;  // 3
        expected_sum = 8'h09;  // 9 (5+3+1)
        expected_cout = 0;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 3: Addition with carry out (iCin = 0)
        test_case = 3;
        iCin = 0;
        iCLA_opA = 8'hFF;  // 255
        iCLA_opB = 8'h01;  // 1
        expected_sum = 8'h00;  // 0 (with carry out)
        expected_cout = 1;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 4: Addition with carry out (iCin = 1)
        test_case = 4;
        iCin = 1;
        iCLA_opA = 8'hFF;  // 255
        iCLA_opB = 8'h01;  // 1
        expected_sum = 8'h01;  // 1 (255+1+1=257, output=1 with carry)
        expected_cout = 1;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 5: Zero inputs with iCin = 0
        test_case = 5;
        iCin = 0;
        iCLA_opA = 8'h00;  // 0
        iCLA_opB = 8'h00;  // 0
        expected_sum = 8'h00;  // 0
        expected_cout = 0;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 6: Zero inputs with iCin = 1
        test_case = 6;
        iCin = 1;
        iCLA_opA = 8'h00;  // 0
        iCLA_opB = 8'h00;  // 0
        expected_sum = 8'h01;  // 1 (0+0+1)
        expected_cout = 0;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 7: Large numbers with iCin = 0
        test_case = 7;
        iCin = 0;
        iCLA_opA = 8'h7F;  // 127
        iCLA_opB = 8'h7F;  // 127
        expected_sum = 8'hFE;  // 254
        expected_cout = 0;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 8: Large numbers with iCin = 1
        test_case = 8;
        iCin = 1;
        iCLA_opA = 8'h7F;  // 127
        iCLA_opB = 8'h7F;  // 127
        expected_sum = 8'hFF;  // 255 (127+127+1)
        expected_cout = 0;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 9: Maximum values with iCin = 0
        test_case = 9;
        iCin = 0;
        iCLA_opA = 8'hFF;  // 255
        iCLA_opB = 8'hFF;  // 255
        expected_sum = 8'hFE;  // 254 (with carry out)
        expected_cout = 1;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 10: Maximum values with iCin = 1
        test_case = 10;
        iCin = 1;
        iCLA_opA = 8'hFF;  // 255
        iCLA_opB = 8'hFF;  // 255
        expected_sum = 8'hFF;  // 255 (510+1=511, output=255 with carry)
        expected_cout = 1;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 11: Random values with iCin = 0
        test_case = 11;
        iCin = 0;
        iCLA_opA = 8'hA5;  // 165
        iCLA_opB = 8'h5A;  // 90
        expected_sum = 8'hFF;  // 255
        expected_cout = 0;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 12: Random values with iCin = 1
        test_case = 12;
        iCin = 1;
        iCLA_opA = 8'hA5;  // 165
        iCLA_opB = 8'h5A;  // 90
        expected_sum = 8'h00;  // 0 (165+90+1=256, output=0 with carry)
        expected_cout = 1;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 13: Alternating bits with iCin = 0
        test_case = 13;
        iCin = 0;
        iCLA_opA = 8'h55;  // 01010101
        iCLA_opB = 8'hAA;  // 10101010
        expected_sum = 8'hFF;  // 11111111
        expected_cout = 0;
        #(CLK_PERIOD);
        verify_result();
        
        // Test Case 14: Alternating bits with iCin = 1
        test_case = 14;
        iCin = 1;
        iCLA_opA = 8'h55;  // 01010101
        iCLA_opB = 8'hAA;  // 10101010
        expected_sum = 8'h00;  // 00000000 (with carry out)
        expected_cout = 1;
        #(CLK_PERIOD);
        verify_result();
        
        // Display test summary
        $display("----------------------------------------");
        $display("Test Completed: %0d test cases run with %0d errors", test_case, errors);
        $display("----------------------------------------");
        
        // End simulation
        #(CLK_PERIOD*2);
        $finish;
    end
    
    // Task to verify the results
    task verify_result;
        begin
            #1; // Small delay to allow outputs to stabilize
            if (oCLA_Sum !== expected_sum || oCout !== expected_cout) begin
                $display("%9d | %4b | %8h | %8h | %11h | %8h | %13b | %5b | FAIL", 
                        test_case, iCin, iCLA_opA, iCLA_opB, expected_sum, oCLA_Sum, expected_cout, oCout);
                errors = errors + 1;
            end else begin
                $display("%9d | %4b | %8h | %8h | %11h | %8h | %13b | %5b | PASS", 
                        test_case, iCin, iCLA_opA, iCLA_opB, expected_sum, oCLA_Sum, expected_cout, oCout);
            end
        end
    endtask

endmodule
