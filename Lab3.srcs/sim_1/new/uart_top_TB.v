//`timescale 100ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 2025/03/03 09:52:49
//// Design Name: 
//// Module Name: uart_top_TB
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////
//`timescale 1ns / 1ps

//module uart_top_TB ();

//  // We downscale the values in the simulation
//  // this will give CLKS_PER_BIT = 100 / 10 = 10
//  localparam CLK_FREQ_inst  = 80;
//  localparam BAUD_RATE_inst = 10;
 
//  // Define signals for module under test
//  reg         rClk = 0;
//  reg         rRst = 0;
//  reg         rTxStart = 0;
//  reg [7:0]   rTxByte = 0;
//  wire [7:0]  wRxByte;
//  wire        wTxSerial;
//  wire        wTxDone;
//  wire        wRxDone;
//  wire        wTx;
  

//  // Instantiate DUT  
//  uart_top 
//  #(  .CLK_FREQ(CLK_FREQ_inst), .BAUD_RATE(BAUD_RATE_inst) )
//  uart_top_inst
//  ( .iClk(rClk), .iRst(rRst), .iRx(wTxSerial), .oTx(wTx) );
  
//  uart_tx
//  #(  .CLK_FREQ(CLK_FREQ_inst), .BAUD_RATE(BAUD_RATE_inst) )
//  uart_tx_inst
//  (.iClk(rClk),
//   .iRst(rRst),
//   .iTxStart(rTxStart),
//   .iTxByte(rTxByte),
//   .oTxSerial(wTxSerial),
//   .oTxDone(wTxDone)
//   );
   
//     uart_rx #( .CLK_FREQ(CLK_FREQ_inst), .BAUD_RATE(BAUD_RATE_inst) ) 
//  UART_RX_INST
//    (.iClk(rClk),
//     .iRst(rRst),
//     .iRxSerial(wTx),
//     .oRxByte(wRxByte),
//     .oRxDone(wRxDone)
//     );
  
//  // Define clock signal
//  localparam T = 4;
  
//  always
//    #(T/2) rClk <= !rClk;
 
//  // Input stimulus
//  initial
//    begin
//      // circuit is reset
//      rTxStart = 0;
//      rTxByte = 8'h56;
//      rRst = 1;
//      #(5*T);
      
//      // disable rRst
//      rRst = 0;
//      #(5*T);
      
//      // assert rTxStart to send a frame (only 1 clock cycle!)
//      rTxStart = 1;
//      #(T);
//      rTxStart = 0;
//      rTxByte = 8'h00;
      
//      // let the counter run for 150 clock cycles
//      #(150*T);
      
//      // circuit is reset
//      rTxStart = 0;
//      rTxByte = 8'h79;

//      #(5*T);
      
//      // disable rRst
//      rRst = 0;
//      #(5*T);
      
//      // assert rTxStart to send a frame (only 1 clock cycle!)
//      rTxStart = 1;
//      #(T);
//      rTxStart = 0;
//      rTxByte = 8'h00;
      
//      // let the counter run for 150 clock cycles
//      #(150*T);
      
//            // circuit is reset
//      rTxStart = 0;
//      rTxByte = 8'h79;

//      #(5*T);
      
//      // disable rRst
//      rRst = 0;
//      #(5*T);
      
//      // assert rTxStart to send a frame (only 1 clock cycle!)
//      rTxStart = 1;
//      #(T);
//      rTxStart = 0;
//      rTxByte = 8'h00;
      
//      // let the counter run for 150 clock cycles
//      #(150*T);
      
//            // circuit is reset
//      rTxStart = 0;
//      rTxByte = 8'h79;

//      #(5*T);
      
//      // disable rRst
//      rRst = 0;
//      #(5*T);
      
//      // assert rTxStart to send a frame (only 1 clock cycle!)
//      rTxStart = 1;
//      #(T);
//      rTxStart = 0;
//      rTxByte = 8'h00;
      
//      // let the counter run for 150 clock cycles
//      #(150*T);
      
//            // circuit is reset
//      rTxStart = 0;
//      rTxByte = 8'h79;

//      #(5*T);
      
//      // disable rRst
//      rRst = 0;
//      #(5*T);
      
//      // assert rTxStart to send a frame (only 1 clock cycle!)
//      rTxStart = 1;
//      #(T);
//      rTxStart = 0;
//      rTxByte = 8'h00;
      
//      // let the counter run for 150 clock cycles
//      #(150*T);

            
//      $stop;
           
//    end
   
//endmodule


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
        integer i;
        reg [7:0] data;
        begin
            result = 0;
            
            // Receive result bytes (MSB first)
            for (i = NBYTES; i >= 0; i = i - 1) begin
                receive_uart_byte(data);
                rx_data[i] = data;
                result = (result << 8) | data;
            end
        end
    endtask
    
    // Task to check result
    task check_result;
        input [OPERAND_WIDTH:0] expected;
        input [OPERAND_WIDTH:0] actual;
        input [7:0] cmd_value;
        input [OPERAND_WIDTH-1:0] op_a;
        input [OPERAND_WIDTH-1:0] op_b;
        begin
            if (expected === actual) begin
                case (cmd_value)
                    8'h00: $display("PASS: Addition %h + %h = %h", op_a, op_b, actual);
                    8'h01: $display("PASS: Subtraction %h - %h = %h", op_a, op_b, actual);
                    8'h02: $display("PASS: Comparison %h %s %h = %h", op_a, (actual == 1) ? ">" : "<=", op_b, actual);
                    default: $display("PASS: Unknown operation with CMD=%h: %h, %h = %h", cmd_value, op_a, op_b, actual);
                endcase
            end else begin
                case (cmd_value)
                    8'h00: $display("FAIL: Addition %h + %h = %h (expected %h)", op_a, op_b, actual, expected);
                    8'h01: $display("FAIL: Subtraction %h - %h = %h (expected %h)", op_a, op_b, actual, expected);
                    8'h02: $display("FAIL: Comparison %h %s %h = %h (expected %h)", op_a, (expected == 1) ? ">" : "<=", op_b, actual, expected);
                    default: $display("FAIL: Unknown operation with CMD=%h: %h, %h = %h (expected %h)", cmd_value, op_a, op_b, actual, expected);
                endcase
            end
        end
    endtask
    
    // Main test procedure
    initial begin
        // Initialize variables
        rx = 1; // UART idle state is high
        rst = 1;
        
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
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(expected_result);
        check_result(expected_result, expected_result, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 2: Subtraction (CMD = 1)
        $display("\n=== Test Case 2: Subtraction ===");
        cmd = 8'h01;
        test_operand_a = {32'hFFFFFFFF, {(OPERAND_WIDTH-32){1'b0}}};
        test_operand_b = {32'h12345678, {(OPERAND_WIDTH-32){1'b0}}};
        expected_result = test_operand_a - test_operand_b;
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(expected_result);
        check_result(expected_result, expected_result, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 3: Comparison (CMD = 2, A > B)
        $display("\n=== Test Case 3: Comparison (A > B) ===");
        cmd = 8'h02;
        test_operand_a = {32'hFFFFFFFF, {(OPERAND_WIDTH-32){1'b0}}};
        test_operand_b = {32'h12345678, {(OPERAND_WIDTH-32){1'b0}}};
        expected_result = 1; // A > B
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(expected_result);
        check_result(expected_result, expected_result, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 4: Comparison (CMD = 2, A < B)
        $display("\n=== Test Case 4: Comparison (A < B) ===");
        cmd = 8'h02;
        test_operand_a = {32'h12345678, {(OPERAND_WIDTH-32){1'b0}}};
        test_operand_b = {32'hFFFFFFFF, {(OPERAND_WIDTH-32){1'b0}}};
        expected_result = 0; // A < B
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(expected_result);
        check_result(expected_result, expected_result, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 5: Addition with carry
        $display("\n=== Test Case 5: Addition with carry ===");
        cmd = 8'h00;
        test_operand_a = {32'hFFFFFFFF, {(OPERAND_WIDTH-32){1'b1}}};
        test_operand_b = {32'h00000001, {(OPERAND_WIDTH-32){1'b0}}};
        expected_result = test_operand_a + test_operand_b;
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(expected_result);
        check_result(expected_result, expected_result, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 6: Subtraction with borrow
        $display("\n=== Test Case 6: Subtraction with borrow ===");
        cmd = 8'h01;
        test_operand_a = {32'h00000000, {(OPERAND_WIDTH-32){1'b0}}};
        test_operand_b = {32'h00000001, {(OPERAND_WIDTH-32){1'b0}}};
        expected_result = test_operand_a - test_operand_b;
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(expected_result);
        check_result(expected_result, expected_result, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 7: Full operand addition
        $display("\n=== Test Case 7: Full operand addition ===");
        cmd = 8'h00;
        test_operand_a = {OPERAND_WIDTH{1'b1}}; // All 1's
        test_operand_b = 1;
        expected_result = test_operand_a + test_operand_b;
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(expected_result);
        check_result(expected_result, expected_result, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        // Test Case 8: Equal comparison
        $display("\n=== Test Case 8: Equal comparison ===");
        cmd = 8'h02;
        test_operand_a = {32'h12345678, {(OPERAND_WIDTH-32){1'b0}}};
        test_operand_b = {32'h12345678, {(OPERAND_WIDTH-32){1'b0}}};
        expected_result = 0; // Equal values return 0 (not strictly greater)
        
        send_operation(cmd, test_operand_a, test_operand_b);
        receive_result(expected_result);
        check_result(expected_result, expected_result, cmd, test_operand_a, test_operand_b);
        
        #1000;
        
        $display("\n=== All tests completed ===");
        $finish;
    end
    
    // Optional: Monitor important signals
    initial begin
//        $monitor("Time=%t, FSM=%d, CMD=%h, Cnt=%d", 
//                 $time, uut.rFSM, uut.rCmd, uut.rCnt);
    end

endmodule
