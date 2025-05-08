`timescale 1ns / 1ps

module uart_top_tb();
    // Parameters
    parameter OPERAND_WIDTH = 512;
    parameter ADDER_WIDTH = 32;
    parameter CLK_FREQ = 125_000_000;
    parameter BAUD_RATE = 115_200;
    parameter CLK_PERIOD = 8; // 125MHz clock period in ns
    parameter BIT_PERIOD = 1_000_000_000 / BAUD_RATE; // Bit period in ns
    parameter NBYTES = OPERAND_WIDTH/8;
    
    // Testbench signals
    reg clk;
    reg rst;
    reg rx;
    wire tx;
    
    // UART input/output byte arrays
    reg [7:0] tx_data [0:NBYTES+1]; // CMD + operands
    reg [7:0] rx_data [0:NBYTES];   // Result bytes
    
    // Test values
    reg [OPERAND_WIDTH-1:0] test_operand_a;
    reg [OPERAND_WIDTH-1:0] test_operand_b;
    reg [OPERAND_WIDTH:0] expected_result;
    reg expected_overflow;
    reg [OPERAND_WIDTH:0] expected_result_6;
    reg expected_overflow_6;
    reg [OPERAND_WIDTH:0] actual_result;
    reg actual_overflow;
    reg [7:0] cmd;
    
    // Instantiate the Unit Under Test (UUT)
    uart_top #(
        .OPERAND_WIDTH(OPERAND_WIDTH),
        .ADDER_WIDTH(ADDER_WIDTH),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .iClk(clk),
        .iRst(rst),
        .iRx(rx),
        .oTx(tx)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Task to send a byte over UART
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Start bit
            rx = 0;
            #BIT_PERIOD;
            
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #BIT_PERIOD;
            end
            
            // Stop bit
            rx = 1;
            #BIT_PERIOD;
        end
    endtask
    
    // Task to receive a byte over UART
    task receive_uart_byte;
        output [7:0] data;
        integer i;
        begin
            // Wait for start bit (tx goes low)
            wait(tx == 0);
            #(BIT_PERIOD/2); // Sample in the middle of the bit
            
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                #BIT_PERIOD;
                data[i] = tx;
            end
            
            // Wait for stop bit
            #BIT_PERIOD;
        end
    endtask
    
    // Task to send operands and command
    task send_operation;
        input [7:0] command;
        input [OPERAND_WIDTH-1:0] operand_a;
        input [OPERAND_WIDTH-1:0] operand_b;
        integer i;
        begin
            // Send command byte first
            send_uart_byte(command);
            
            // Send operand A bytes (MSB first)
            for (i = NBYTES-1; i >= 0; i = i - 1) begin
                send_uart_byte(operand_a[i*8 +: 8]);
            end
            
            // Send operand B bytes (MSB first)
            for (i = NBYTES-1; i >= 0; i = i - 1) begin
                send_uart_byte(operand_b[i*8 +: 8]);
            end
        end
    endtask
    
    // Task to receive result
    task receive_result;
        output [OPERAND_WIDTH:0] result;
        output overflow;
        integer i;
        reg [7:0] data;
        begin
            result = 0;
            
            // Receive result bytes (MSB first)
            for (i = NBYTES; i >= 0; i = i - 1) begin
                receive_uart_byte(data);
                rx_data[i] = data;
                // First byte contains the overflow bit in LSB
                if (i == NBYTES) begin
                    overflow = data[1]; // Extract overflow bit
                    data = data &~(1 << 1); // Clear overflow bit for result calculation
                end
                result = (result << 8) | data;
            end
        end
    endtask
    
    // Task to check result
    task check_result;
        input [OPERAND_WIDTH:0] expected;
        input expected_of;
        input [OPERAND_WIDTH:0] actual;
        input actual_of;
        input [7:0] cmd_value;
        input [OPERAND_WIDTH-1:0] op_a;
        input [OPERAND_WIDTH-1:0] op_b;
        begin
            if (expected === actual && expected_of === actual_of) begin
                case (cmd_value)
                    8'h00: $display("PASS: Addition %h + %h = %h, Overflow: %b", op_a, op_b, actual, actual_of);
                    8'h01: $display("PASS: Subtraction %h - %h = %h, Overflow: %b", op_a, op_b, actual, actual_of);
                    8'h02: $display("PASS: Comparison %h %s %h = %h", op_a, (actual == 1) ? ">=" : "<", op_b, actual);
                    default: $display("PASS: Unknown operation with CMD=%h: %h, %h = %h, Overflow: %b", cmd_value, op_a, op_b, actual, actual_of);
                endcase
            end else begin
                case (cmd_value)
                    8'h00: $display("FAIL: Addition %h + %h = %h (expected %h), Overflow: %b (expected %b)", op_a, op_b, actual, expected, actual_of, expected_of);
                    8'h01: $display("FAIL: Subtraction %h - %h = %h (expected %h), Overflow: %b (expected %b)", op_a, op_b, actual, expected, actual_of, expected_of);
                    8'h02: $display("FAIL: Comparison %h %s %h = %h (expected %h)", op_a, (expected == 1) ? ">=" : "<", op_b, actual, expected);
                    default: $display("FAIL: Unknown operation with CMD=%h: %h, %h = %h (expected %h), Overflow: %b (expected %b)", cmd_value, op_a, op_b, actual, expected, actual_of, expected_of);
                endcase
            end
        end
    endtask
    
    // Helper function to mask operands for subtraction and comparison
    // For these operations, we use [OPERAND_WIDTH-2:0] bits
    function [OPERAND_WIDTH-1:0] mask_operand;
        input [OPERAND_WIDTH-1:0] operand;
        begin
            mask_operand = operand & {2'b00, {(OPERAND_WIDTH-2){1'b1}}};
        end
    endfunction
    
    // Function to detect overflow for subtraction in two's complement
    function detect_overflow_sub;
        input [OPERAND_WIDTH-1:0] a;
        input [OPERAND_WIDTH-1:0] b;
        input [OPERAND_WIDTH-1:0] result;
        begin
            // Overflow occurs when:
            // (A is positive, B is negative, result is negative) OR
            // (A is negative, B is positive, result is positive)
            detect_overflow_sub = ((a[OPERAND_WIDTH-1] == 0 && b[OPERAND_WIDTH-1] == 1 && result[OPERAND_WIDTH-1] == 1) || 
                                   (a[OPERAND_WIDTH-1] == 1 && b[OPERAND_WIDTH-1] == 0 && result[OPERAND_WIDTH-1] == 0));
        end
    endfunction
    
    // Main test procedure
    initial begin
        // Initialize variables
        rx = 1; // UART idle state is high
        rst = 1;
        expected_overflow = 0;
        expected_overflow_6 = 0;
        
        // Apply reset
        #100;
        rst = 0;
        #100;
        
        // Test Case 1: Addition (CMD = 0)
        $display("\n=== Test Case 1: Addition ===");
        cmd = 8'h00;
        test_operand_a = {32'h12345678, {(OPERAND_WIDTH-32){1'b0}}};
        test_operand_b = {32'h87654321, {(OPERAND_WIDTH-32){1'b0}}};
        expected_result = test_operand_a + test_operand_b;
        expected_overflow = 0; // No overflow expected
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 2: Subtraction (CMD = 1)
        $display("\n=== Test Case 2: Subtraction ===");
        cmd = 8'h01;
        // For subtraction, use [OPERAND_WIDTH-2:0] bits
        test_operand_a = mask_operand({32'hEFFFFFFF, {(OPERAND_WIDTH-32){1'b0}}});
        test_operand_b = mask_operand({32'h12345678, {(OPERAND_WIDTH-32){1'b0}}});
        expected_result = test_operand_a - test_operand_b;
        // Calculate expected overflow
        expected_overflow = detect_overflow_sub(test_operand_a, test_operand_b, expected_result[OPERAND_WIDTH-1:0]);
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 3: Comparison (CMD = 2, A > B)
        $display("\n=== Test Case 3: Comparison (A > B) ===");
        cmd = 8'h02;
        // For comparison, use [OPERAND_WIDTH-2:0] bits
        test_operand_a = mask_operand({32'hFFFFFFFF, {(OPERAND_WIDTH-32){1'b0}}});
        test_operand_b = mask_operand({32'h12345678, {(OPERAND_WIDTH-32){1'b0}}});
        // A > B, so result should be 1
        expected_result = 1; 
        expected_overflow = 0; // Not applicable for comparison
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 4: Comparison (CMD = 2, A < B)
        $display("\n=== Test Case 4: Comparison (A < B) ===");
        cmd = 8'h02;
        // For comparison, use [OPERAND_WIDTH-2:0] bits
        test_operand_a = mask_operand({32'h12345678, {(OPERAND_WIDTH-32){1'b0}}});
        test_operand_b = mask_operand({32'hFFFFFFFF, {(OPERAND_WIDTH-32){1'b0}}});
        // A < B, so result should be 0
        expected_result = 0;
        expected_overflow = 0; // Not applicable for comparison
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 5: Addition with carry
        $display("\n=== Test Case 5: Addition with carry ===");
        cmd = 8'h00;
        test_operand_a = {32'hFFFFFFFF, {(OPERAND_WIDTH-32){1'b1}}};
        test_operand_b = {32'h00000001, {(OPERAND_WIDTH-32){1'b0}}};
        expected_result = test_operand_a + test_operand_b;
        expected_overflow = 0; // Not an overflow in two's complement
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 6: Subtraction with borrow
        $display("\n=== Test Case 6: Subtraction with borrow ===");
        cmd = 8'h01;
        // For subtraction, use [OPERAND_WIDTH-2:0] bits
        test_operand_a = mask_operand({32'h00000000, {(OPERAND_WIDTH-32){1'b0}}});
        test_operand_b = mask_operand({32'h00001111, {(OPERAND_WIDTH-32){1'b0}}});
        expected_result_6 = test_operand_a - test_operand_b;
        // Calculate expected overflow
        expected_overflow_6 = detect_overflow_sub(test_operand_a, test_operand_b, expected_result_6[OPERAND_WIDTH-1:0]);
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result_6, expected_overflow_6, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 7: Full operand addition
        $display("\n=== Test Case 7: Full operand addition ===");
        cmd = 8'h00;
        test_operand_a = {OPERAND_WIDTH{1'b1}}; // All 1's
        test_operand_b = 1;
        expected_result = test_operand_a + test_operand_b;
        expected_overflow = 0; // No overflow in two's complement
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 8: Equal comparison
        $display("\n=== Test Case 8: Equal comparison ===");
        cmd = 8'h02;
        // For comparison, use [OPERAND_WIDTH-2:0] bits
        test_operand_a = mask_operand({32'h12345678, {(OPERAND_WIDTH-32){1'b0}}});
        test_operand_b = mask_operand({32'h12345678, {(OPERAND_WIDTH-32){1'b0}}});
        // A = B, so result should be 1 (A >= B)
        expected_result = 1;
        expected_overflow = 0; // Not applicable for comparison
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 9: Subtraction with overflow (positive - negative = negative)
        $display("\n=== Test Case 9: Subtraction with overflow (positive - negative = negative) ===");
        cmd = 8'h01;
        // Test case where A is positive (sign bit 0), B is negative (sign bit 1)
        // and result should be negative (sign bit 1) - this causes overflow
        test_operand_a = mask_operand({1'b0, {(OPERAND_WIDTH-1){1'b0}}}); // Small positive number
        test_operand_b = mask_operand({1'b1, {(OPERAND_WIDTH-1){1'b1}}}); // Large negative number
        expected_result = test_operand_a - test_operand_b;
        expected_overflow = 1; // Overflow expected
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 10: Subtraction with overflow (negative - positive = positive)
        $display("\n=== Test Case 10: Subtraction with overflow (negative - positive = positive) ===");
        cmd = 8'h01;
        // Test case where A is negative (sign bit 1), B is positive (sign bit 0)
        // and result should be positive (sign bit 0) - this causes overflow
        test_operand_a = mask_operand({1'b1, {(OPERAND_WIDTH-1){1'b0}}}); // Large negative number
        test_operand_b = mask_operand({1'b0, {(OPERAND_WIDTH-1){1'b1}}}); // Large positive number
        expected_result = test_operand_a - test_operand_b;
        expected_overflow = 1; // Overflow expected
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(actual_result, actual_overflow);
        check_result(expected_result, expected_overflow, actual_result, actual_overflow, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        $display("\n=== All tests completed ===");
        $finish;
    end
    
    // Optional: Monitor important signals
    initial begin
        // Uncomment if you want to monitor specific signals
        // $monitor("Time=%t, FSM=%d, CMD=%h, Cnt=%d", 
        //          $time, uut.rFSM, uut.rCmd, uut.rCnt);
    end

endmodule